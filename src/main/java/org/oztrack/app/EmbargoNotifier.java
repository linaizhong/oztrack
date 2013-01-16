package org.oztrack.app;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.PersistenceUnit;

import org.apache.commons.lang3.time.DateUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.oztrack.data.access.impl.ProjectDaoImpl;
import org.oztrack.data.model.Project;
import org.oztrack.util.EmailBuilder;
import org.springframework.stereotype.Service;

@Service
public class EmbargoNotifier implements Runnable {
    protected final Log logger = LogFactory.getLog(getClass());

    private SimpleDateFormat isoDateFormat = new SimpleDateFormat("yyyy-MM-dd");

    @PersistenceUnit
    private EntityManagerFactory entityManagerFactory;

    public EmbargoNotifier() {
    }

    @Override
    public void run() {
        logger.info("Running embargo notifier.");
        EntityManager entityManager = entityManagerFactory.createEntityManager();
        ProjectDaoImpl projectDao = new ProjectDaoImpl();
        projectDao.setEntityManger(entityManager);
        sendNotifications(entityManager, projectDao, Calendar.MONTH, 2);
    }

    // Note: successive calls to this method should be performed with earlier expiry dates first.
    // See code below that skips notification for a project if one already sent for an equal or shorter period.
    private void sendNotifications(EntityManager entityManager, ProjectDaoImpl projectDao, int field, int amount) {
        Calendar expiryCalendar = new GregorianCalendar();
        expiryCalendar.add(field, amount);
        Date expiryDate = DateUtils.truncate(expiryCalendar.getTime(), Calendar.DATE);
        List<Project> projects = projectDao.getProjectsWithExpiredEmbargo(expiryDate);

        for (Project project : projects) {
            // If notification has been sent for an earlier or equal expiry date, e.g. a one-week
            // notification has been sent and we're preparing to send two-month notifications here,
            // then skip this project. It doesn't make sense to send both if we are already in the
            // shorter period before expiry due to the scheduler not being run for a while - or to
            // send duplicate notifications for the same date.
            if (!expiryDate.before(project.getEmbargoNotificationDate())) {
                continue;
            }
            logger.info(
                "Sending notification for project " + project.getId() + " " +
                "(embargo expires " + isoDateFormat.format(project.getEmbargoDate()) + ")."
            );
            EntityTransaction transaction = entityManager.getTransaction();
            transaction.begin();
            try {
                EmailBuilder emailBuilder = new EmailBuilder();
                emailBuilder.to(project.getCreateUser());
                emailBuilder.subject("OzTrack project embargo ending");
                StringBuilder htmlMsgContent = new StringBuilder();
                htmlMsgContent.append("<p>");
                htmlMsgContent.append("    Please note that your OzTrack project,\n");
                htmlMsgContent.append("    <b>" + project.getTitle() + "</b>, will end its embargo period on ");
                htmlMsgContent.append("    " + isoDateFormat.format(project.getEmbargoDate()) + ".\n");
                htmlMsgContent.append("</p>\n");
                htmlMsgContent.append("<p>");
                htmlMsgContent.append("    Following this date, data in this project will be made publicly available via OzTrack.");
                htmlMsgContent.append("</p>");
                emailBuilder.htmlMsgContent(htmlMsgContent.toString());
                emailBuilder.build().send();

                project.setEmbargoNotificationDate(expiryDate);
                projectDao.update(project);
                transaction.commit();
            }
            catch (Exception e) {
                logger.error("Exception in embargo notifier", e);
                try {transaction.rollback();} catch (Exception e2) {}
            }
        }
    }
}
