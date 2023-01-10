package com.intacct.ds.template.service;


import com.intacct.core.orm.entity.EntityManager;
import com.intacct.core.service.EntityService;
import com.intacct.ds.template.model.Dummy;


public class DummyService extends EntityService<Dummy> {

    public DummyService(EntityManager<Dummy> manager) {
        super(manager);
    }

    @Override
    protected Class<Dummy> getEntityClass() {
        return Dummy.class;
    }

}
