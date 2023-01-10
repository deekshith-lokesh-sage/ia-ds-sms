package com.intacct.ds.dummy.service;

import com.intacct.core.service.IService;
import com.intacct.ds.dummy.model.TextAndRequestDTO;
import com.intacct.ds.dummy.model.TextAndResponseDTO;

public class TextService implements IService {
    public TextAndResponseDTO andFunction(TextAndRequestDTO request) {
        return new TextAndResponseDTO(request.getText() + " and " + request.getOtherText());
    }
}
