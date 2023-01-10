package com.intacct.ds.dummy.model;

import com.intacct.core.model.DTO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@AllArgsConstructor
public class TextAndResponseDTO extends DTO {
    String phrase;
}
