package com.intacct.ds.dummy.model;

import com.intacct.core.model.DTO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@EqualsAndHashCode(callSuper = true)
@AllArgsConstructor
@NoArgsConstructor
public class TextAndResponseDTO extends DTO {
    String phrase;
}
