package com.intacct.ds.template.model;

import com.intacct.core.model.EntityDTO;
import com.intacct.core.model.enums.StatusEnum;
import com.intacct.core.orm.annotation.EntityInfoAnnotation;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@EntityInfoAnnotation(directory = "template")
public class Dummy extends EntityDTO {
    private String name;
    private StatusEnum status;
    private Double totalDue;
    private String comments;
    private String taxId;
    private Double creditLimit;
    private Double discount;

    private Long parentKey;
    private Dummy parent;

    private Contact displayContact;
    private Long displayContactKey;

    private Contact contactInfo;
    private Long contactInfoKey;

    private Contact payTo;
    private Long payToKey;

    private Contact returnTo;
    private Long returnToKey;

    private Contact contactTo1099;
    private Long contactKey1099;

    @Override
    public String toString() {
        return "Vendor{" +
                "name='" + name + '\'' +
                ", status='" + status.getValue() + '\'' +
                ", totalDue=" + totalDue +
                ", comments='" + comments + '\'' +
                ", taxId='" + taxId + '\'' +
                ", creditLimit=" + creditLimit +
                ", discount=" + discount +
                '}';
    }
}
