package com.intacct.ds.dummy.model;

import com.intacct.core.model.EntityDTO;
import com.intacct.core.model.types.BooleanType;
import com.intacct.core.model.types.StatusType;
import com.intacct.core.orm.annotation.EntityInfoAnnotation;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@EntityInfoAnnotation(directory = "dummy")
public class Contact extends EntityDTO {
    private String companyName;
    private String prefix;
    private String firstName;
    private String lastName;
    private String initial;
    private String printAs;
    private BooleanType taxable;
    private Long taxGroupKey;
    private String phone1;
    private String email1;
    private StatusType status;

    private Long priceListKey;

    private Long mailAddressKey;
    private MailAddress mailAddress;

}
