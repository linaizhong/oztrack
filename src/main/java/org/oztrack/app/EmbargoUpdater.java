package org.oztrack.app;

import java.text.SimpleDateFormat;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.PersistenceUnit;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.oztrack.data.access.impl.ProjectDaoImpl;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.types.ProjectAccess;
import org.springframework.stereotype.Service;

@Service
public class EmbargoUpdater implements Runnable {
    protected final Log logger = LogFactory.getLog(getClass());

    private SimpleDateFormat isoDateFormat = new SimpleDateFormat("yyyy-MM-dd");

    @PersistenceUnit
    private EntityManagerFactory entityManagerFactory;

    public EmbargoUpdater() {
    }

    @Override
    public void run() {
        EntityManager entityManager = entityManagerFactory.createEntityManager();
        ProjectDaoImpl projectDao = new ProjectDaoImpl();
        projectDao.setEntityManger(entityManager);

        EntityTransaction transaction = entityManager.getTransaction();
        transaction.begin();
        try {
            List<Project> projects = projectDao.getProjectsWithExpiredEmbargo();
            for (Project project : projects) {
                logger.info(
                    "Making project " + project.getId() + " open access " +
                    "(embargo expired " + isoDateFormat.format(project.getEmbargoDate()) + ")."
                );
                project.setAccess(ProjectAccess.OPEN);
                projectDao.update(project);
            }
            transaction.commit();
        }
        catch (Exception e) {
            logger.error("Exception in embargo updater", e);
            try {transaction.rollback();} catch (Exception e2) {}
        }
    }
}