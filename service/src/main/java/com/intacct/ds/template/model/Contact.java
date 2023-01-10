package com.intacct.ds.template.model;

import com.intacct.core.model.EntityDTO;
import com.intacct.core.model.enums.StatusEnum;
import com.intacct.core.orm.annotation.EntityInfoAnnotation;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@EntityInfoAnnotation(directory = "template")
public class Contact extends EntityDTO {
    private String companyName;
    private String prefix;
    private String firstName;
    private String lastName;
    private String initial;
    private String printAs;
    private Boolean taxable;
    private Long taxGroupKey;
    private String phone1;
    private String email1;
    private StatusEnum status;

    private Long priceListKey;

    private Long mailAddressKey;
    private MailAddress mailAddress;

}
