package org.oztrack.data.access.impl;

import java.util.Date;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import org.oztrack.data.access.InstitutionDao;
import org.oztrack.data.model.Institution;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class InstitutionDaoImpl implements InstitutionDao {
    private EntityManager em;

    @PersistenceContext
    public void setEntityManager(EntityManager em) {
        this.em = em;
    }

    @Override
    public List<Institution> getAll() {
        @SuppressWarnings("unchecked")
        List<Institution> resultList = em.createQuery("from org.oztrack.data.model.Institution order by id").getResultList();
        return resultList;
    }

    @Override
    public List<Institution> getAllOrderedByTitle() {
        @SuppressWarnings("unchecked")
        List<Institution> resultList = em.createQuery("from org.oztrack.data.model.Institution order by title").getResultList();
        return resultList;
    }

    @Override
    public Institution getById(Long id) {
        @SuppressWarnings("unchecked")
        List<Institution> resultList = em
            .createQuery("from org.oztrack.data.model.Institution where id = :id")
            .setParameter("id", id)
            .getResultList();
        return resultList.isEmpty() ? null : resultList.get(0);
    }

    @Override
    public Institution getByTitle(String title) {
        @SuppressWarnings("unchecked")
        List<Institution> resultList = em
            .createQuery("from org.oztrack.data.model.Institution where lower(title) = lower(:title)")
            .setParameter("title", title)
            .getResultList();
        return resultList.isEmpty() ? null : resultList.get(0);
    }

    @Override
    @Transactional
    public void save(Institution institution) {
        em.persist(institution);
    }

    @Override
    @Transactional
    public Institution update(Institution institution) {
        return em.merge(institution);
    }

    @Override
    @Transactional
    public void delete(Institution institution) {
        em.remove(institution);
    }

    @Override
    public List<Institution> getInstitutionsForOaiPmh(Date from, Date until, String setSpec) {
        return DaoHelper.getEntitiesForOaiPmh(em, Institution.class, from, until, setSpec);
    }
}
