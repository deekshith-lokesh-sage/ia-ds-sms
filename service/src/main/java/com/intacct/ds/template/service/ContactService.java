package com.intacct.ds.template.service;


import com.intacct.core.orm.entity.EntityManager;
import com.intacct.core.service.EntityService;
import com.intacct.ds.template.model.Contact;


public class ContactService extends EntityService<Contact> {

    public ContactService(EntityManager<Contact> manager) {
        super(manager);
    }

    @Override
    protected Class<Contact> getEntityClass() {
        return Contact.class;
    }

}
