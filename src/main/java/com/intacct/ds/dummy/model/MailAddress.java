package com.intacct.ds.dummy.model;

import com.intacct.core.model.EntityDTO;
import com.intacct.core.model.types.StatusType;
import com.intacct.core.orm.annotation.EntityInfoAnnotation;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@EntityInfoAnnotation(directory = "dummy")
public class MailAddress extends EntityDTO {
    Long recordKey;
    String address1;
    String address2;
    String city;
    String state;
    String zip;
    String country;
    String countryCode;
    StatusType status;
    Double latitude;
    Double longitude;

    @Override
    public String toString() {
        return "MailAddress{" +
                "recordKey=" + recordKey +
                ", address1='" + address1 + '\'' +
                ", address2='" + address2 + '\'' +
                ", city='" + city + '\'' +
                ", state='" + state + '\'' +
                ", zip='" + zip + '\'' +
                ", country='" + country + '\'' +
                ", countryCode='" + countryCode + '\'' +
                ", status='" + status.getLabel() + '\'' +
                ", latitude=" + latitude +
                ", longitude=" + longitude +
                '}';
    }
}
