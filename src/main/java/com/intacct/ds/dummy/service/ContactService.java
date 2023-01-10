package com.intacct.ds.dummy.service;


import com.intacct.core.orm.entity.EntityManager;
import com.intacct.core.service.EntityService;
import com.intacct.ds.dummy.model.Contact;


public class ContactService extends EntityService<Contact> {

    public ContactService(EntityManager<Contact> manager) {
        super(manager);
    }

    @Override
    protected Class<Contact> getEntityClass() {
        return Contact.class;
    }

}
