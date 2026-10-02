/**
 * File customizer.js.
 *
 * Theme Customizer enhancements for a better user experience.
 *
 * Contains handlers to make Theme Customizer preview reload changes asynchronously.
 */

(function ($) {
    var $header = $('#site-header'),
        $navigation_dropdown = $('#site-header li:not(.mega-menu-col)>.navigation-dropdown'),
        $navigation_submenu = $('#site-header .navigation-megamenu'),
        $navigation_body = $('#site-header .navigation-body'),
        $stunning = $('#stunning-header'),
        $footer = $('#site-footer'),
        $subscribe = $('#subscribe-section');

    // Header options.
    wp.customize('seosight_customize_options[header_bg_color]', function (value) {
        value.bind(function (newval) {
            $header.css({'backgroundColor': newval});
            $navigation_dropdown.css({'backgroundColor': newval});
            $navigation_submenu.css({'backgroundColor': newval});
            $navigation_body.css({'backgroundColor': newval});
        });
    });

    /*Stunning header*/
    wp.customize('seosight_customize_options[stunning_text_color]', function (value) {
        value.bind(function (newval) {
            $stunning.addClass('font-color-custom');
            $stunning.css({"color": newval});
        });
    });
    wp.customize('seosight_customize_options[stunning_bg_color]', function (value) {
        value.bind(function (newval) {
            $stunning.css({'backgroundColor': newval});
        });
    });
    /*subscribe customize*/
    wp.customize('seosight_customize_options[subscribe_text_color]', function (value) {
        value.bind(function (newval) {
            $subscribe.addClass('font-color-custom');
            $subscribe.css({"color": newval});
        });
    });
    wp.customize('seosight_customize_options[subscribe_bg_cover]', function (value) {
        value.bind(function (newval) {
            if (newval == 1) {
                $subscribe.css({'backgroundSize': 'cover'});
            } else {
                $subscribe.css({'backgroundSize': 'inherit'});
            }
        });
    });
    wp.customize('seosight_customize_options[subscribe_bg_color]', function (value) {
        value.bind(function (newval) {
            $subscribe.css({'backgroundColor': newval});
        });
    });
    /*Footer customize*/
    wp.customize('seosight_customize_options[footer_text_color]', function (value) {
        value.bind(function (newval) {
            $footer.addClass('font-color-custom');
            $footer.css({"color": newval});
        });
    });
    wp.customize('seosight_customize_options[footer_title_color]', function (value) {
        value.bind(function (newval) {
            $footer.addClass('font-color-custom');
            $('.footer .info .heading .heading-title, #site-footer .contacts-item .content .title, #site-footer a, .footer .info .crumina-heading .heading-title').css({"color": newval});
        });
    });
    wp.customize('seosight_customize_options[footer_bg_cover]', function (value) {
        value.bind(function (newval) {
            if (newval == 1) {
                $footer.css({'backgroundSize': 'cover'});
            } else {
                $footer.css({'backgroundSize': 'inherit'});
            }
        });
    });
    wp.customize('seosight_customize_options[footer_bg_color]', function (value) {
        value.bind(function (newval) {
            $footer.css({'backgroundColor': newval});
        });
    });

    /*Copyright customize*/
    wp.customize('seosight_customize_options[copyright_bg_color]', function (value) {
        value.bind(function (newval) {
            $('.sub-footer').css({'backgroundColor': newval});
        });
    });
    wp.customize('seosight_customize_options[copyright_text_color]', function (value) {
        value.bind(function (newval) {
            $('.site-copyright-text').css('color', newval);
        });
    });

})(jQuery);


//console.log(newval);