package com.intacct.ds.template.service;

import com.intacct.core.Context;
import com.intacct.core.api.framework.service.function.FunctionService;
import com.intacct.ds.template.model.TextAndRequestDTO;
import com.intacct.ds.template.model.TextAndResponseDTO;

public class TextService extends FunctionService {
    public TextService(Context context) {
        super(context);
    }

    public TextAndResponseDTO concatenate(TextAndRequestDTO request) {
        return new TextAndResponseDTO(request.getText() + " and " + request.getOtherText());
    }
}
