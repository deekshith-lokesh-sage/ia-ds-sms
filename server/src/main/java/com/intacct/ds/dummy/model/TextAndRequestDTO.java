package com.intacct.ds.dummy.model;

import com.intacct.core.model.DTO;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class TextAndRequestDTO extends DTO {
    String text;
    String otherText;
}
