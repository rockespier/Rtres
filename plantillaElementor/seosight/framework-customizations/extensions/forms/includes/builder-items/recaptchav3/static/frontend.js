function fw_forms_builder_item_recaptcha_v3_init() {
    if(typeof grecaptcha !== 'undefined'){
        grecaptcha.ready(function() {
            grecaptcha.execute(captcha_site_key.site_key).then(function(token) {
                var captcha_token_els = document.getElementsByClassName('register-captcha-v3-token');
                for (var i = 0; i < captcha_token_els.length; ++i) {
                    var item = captcha_token_els[i];  
                    item.value = token;
                }
            });
        });
    }
}
jQuery(function(){
    fwForm.initAjaxSubmit({
        onErrors: function ( elements, data ) {
            fw_forms_builder_item_recaptcha_v3_init();
        }
    });
});