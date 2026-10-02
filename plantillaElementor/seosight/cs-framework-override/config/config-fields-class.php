<?php

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

class SeosightThemeOptionsFields {

    // Customizer subscribe
    public function customizer_subscribe(){
        $enable_email_subscribers_pl = false;
        if ( function_exists( 'es_subbox' ) ) {
            $enable_email_subscribers_pl = true;
        }

        $options = array(
            array(
                'id'    => 'show_subscribe_section',
                'type'  => 'switcher',
                'title' => esc_html__( 'Show Email subscribe section', 'seosight' ),
                'subtitle' => esc_html__( 'Display or hide section with subscribe form before footer.', 'seosight' ),
                'text_on' => esc_html__('Show', 'seosight'),
                'text_off' => esc_html__('Hide', 'seosight'),
                'text_width' => 70,
                'default' => ( seosight_get_unyson_option( 'show_subscribe_section' ) == 'no' ) ? false : true,
            ),
            array(
                'id'    => 'section-subscribe-form',
                'type'  => 'fieldset',
                'title' => esc_html__( 'Customize Subscribe form', 'seosight' ),
                'fields' => array(
                    array(
                        'id'    => 'title',
                        'title' => esc_html__( 'Title', 'seosight' ),
                        'type'  => 'text',
                        'default' => seosight_get_unyson_option( 'section-subscribe-form/title', '' )
                    ),
                    array(
                        'id'    => 'desc',
                        'title' => esc_html__( 'Description', 'seosight' ),
                        'subtitle' => esc_html__( 'Text that display after subscribe form', 'seosight' ),
                        'type'  => 'textarea',
                        'default' => seosight_get_unyson_option( 'section-subscribe-form/desc', '' )
                    ),
                    array(
                        'id'    => 'enable_email_subscribers',
                        'type'  => 'switcher',
                        'title' => esc_html__( 'Enable Email subscribers plugin integration', 'seosight' ),
                        'text_on' => esc_html__('Yes', 'seosight'),
                        'text_off' => esc_html__('No', 'seosight'),
                        'default' => $enable_email_subscribers_pl
                    ),
                    array(
                        'id'    => 'custom_form_html',
                        'title' => esc_html__( 'Custom form', 'seosight' ),
                        'subtitle' => esc_html__( 'You can use any custom HTML or shortcode here.', 'seosight' ),
                        'type'  => 'textarea',
                        'dependency' => array( 'enable_email_subscribers', '!=', 'true' ),
                        'default' => seosight_get_unyson_option( 'section-subscribe-form/custom-form/yes/html', '' )
                    ),
                    array(
                        'id'    => 'show_form_name_field',
                        'type'  => 'switcher',
                        'title' => esc_html__( 'Name field', 'seosight' ),
                        'subtitle' => esc_html__( 'Add name field to subscribe form', 'seosight' ),
                        'default' => ( seosight_get_unyson_option( 'section-subscribe-form/custom-form/no/name_field/show' ) == '1' ) ? true : false,
                        'dependency' => array( 'enable_email_subscribers', '==', 'true' ),
                    ),
                    array(
                        'id'    => 'show_form_name_field_swap',
                        'type'  => 'switcher',
                        'title' => esc_html__( 'Show name field first?', 'seosight' ),
                        'default' => ( seosight_get_unyson_option( 'section-subscribe-form/custom-form/no/name_field/true/name_field_swap' ) == '1' ) ? true : false,
                        'dependency' => array( 'enable_email_subscribers|show_form_name_field', '==|==', 'true|1' ),
                    ),
                    array(
                        'id'    => 'list',
                        'type'  => 'select',
                        'title' => esc_html__( 'List', 'seosight' ),
                        'subtitle' => esc_html__( 'You can manage lists here: Email Subscribers > Audience > Manage Lists', 'seosight' ),
                        'options' => seosight_get_es_lists( true ),
                        'multiple' => true,
                        'default' => seosight_get_unyson_option( 'section-subscribe-form/list', array() ),
                        'dependency' => array( 'enable_email_subscribers', '==', 'true' ),
                    )
                ),
            ),
            array(
                'id'    => 'subscribe_text_color',
                'type'  => 'color',
                'title' => esc_html__( 'Text Color', 'seosight' ),
                'help'	 => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
                'default' => seosight_get_unyson_option( 'subscribe_text_color' ),
				'transport' => 'postMessage'
            ),
            array(
                'id'    => 'subscribe_bg_color',
                'type'  => 'color',
                'title' => esc_html__( 'Background Color', 'seosight' ),
                'subtitle' => esc_html__( 'If you choose no image to display - that color will be set as background', 'seosight' ),
                'help'	 => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
                'default' => seosight_get_unyson_option( 'subscribe_bg_color' ),
				'transport' => 'postMessage'
            ),
            array(
                'id'    => 'subscribe_bg_image_type',
                'type'  => 'radio',
                'title' => esc_html__( 'Background image', 'seosight' ),
                'subtitle' => esc_html__( 'Select one of images or upload your own pattern', 'seosight' ),
                'options'    => array(
                    'predefined' => esc_html__( 'Predefined images', 'seosight' ),
                    'custom' => esc_html__( 'Custom image', 'seosight' ),
                ),
                'default' => seosight_get_unyson_option( 'subscribe_bg_image/type', 'predefined' )
            ),
            array(
                'id'    => 'subscribe_bg_image_predefined',
                'type'  => 'image_select',
                'title' => false,
                'options' => seosight_backgrounds(),
                'default' => seosight_get_unyson_option( 'subscribe_bg_image/predefined', 'none' ),
                'dependency' => array( 'subscribe_bg_image_type', '==', 'predefined' ),
            ),
            array(
                'id'    => 'subscribe_bg_image_custom',
                'type'  => 'upload',
                'library'  => 'image',
                'title' => false,
                'dependency' => array( 'subscribe_bg_image_type', '==', 'custom' ),
                'default' => seosight_get_unyson_option('subscribe_bg_image/custom', '', 'customizer', 'background')
            ),
            array(
                'id'    => 'subscribe_bg_cover',
                'type'  => 'switcher',
                'title' => esc_html__( 'Expand background', 'seosight' ),
                'subtitle' => esc_html__( 'Don\'t repeat image and expand it to full section background', 'seosight' ),
                'default' => seosight_get_unyson_option( 'subscribe_bg_cover', false ),
				'transport' => 'postMessage'
            ),
            array(
                'id'    => 'subscribe_animated',
                'type'  => 'switcher',
                'title' => esc_html__( 'Images animation', 'seosight' ),
                'subtitle' => esc_html__( 'Images animation when section become visible', 'seosight' ),
                'text_on' => esc_html__('Enable', 'seosight'),
                'text_off' => esc_html__('Disable', 'seosight'),
                'text_width' => 80,
                'default' => seosight_get_unyson_option( 'subscribe_animated', false ),
            ),
            array(
                'id'    => 'section-subscribe-images',
                'type'  => 'fieldset',
                'title' => esc_html__( 'Customize Images', 'seosight' ),
                'fields' => array(
                    array(
                        'id'    => 'image_1',
                        'type'  => 'upload',
                        'library'  => 'image',
                        'title' => esc_html__( 'Image', 'seosight' ),
                        'subtitle' => esc_html__( 'Image that uprear from bottom', 'seosight' ),
                        'default' => seosight_get_unyson_option('section-subscribe-images/image_1/url'),
                    ),
                    array(
                        'id'    => 'image_2',
                        'type'  => 'upload',
                        'library'  => 'image',
                        'title' => esc_html__( 'Image', 'seosight' ),
                        'subtitle' => esc_html__( 'Image that uprear from right', 'seosight' ),
                        'default' => seosight_get_unyson_option('section-subscribe-images/image_2/url'),
                    ),
                    array(
                        'id'    => 'image_3',
                        'type'  => 'upload',
                        'library'  => 'image',
                        'title' => esc_html__( 'Image', 'seosight' ),
                        'subtitle' => esc_html__( 'Image that rotating', 'seosight' ),
                        'default' => seosight_get_unyson_option('section-subscribe-images/image_3/url'),
                    ),
                ),
            )
        );

        return $options;
    }

    // Metabox subscribe
    public function metabox_subscribe($current_post_id = 0){
        $options = array(
            array(
                'id'    => 'subscribe_text_color',
                'type'  => 'color',
                'title' => esc_html__( 'Text Color', 'seosight' ),
                'help'	 => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
                'default' => seosight_get_unyson_option( 'custom-subscribe/yes/subscribe-show/yes/subscribe_text_color', '', 'meta/' . $current_post_id ),
				'transport' => 'postMessage'
            ),
            array(
                'id'    => 'subscribe_bg_color',
                'type'  => 'color',
                'title' => esc_html__( 'Background Color', 'seosight' ),
                'subtitle' => esc_html__( 'If you choose no image to display - that color will be set as background', 'seosight' ),
                'help'	 => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
                'default' => seosight_get_unyson_option( 'custom-subscribe/yes/subscribe-show/yes/subscribe_bg_color', '', 'meta/' . $current_post_id ),
				'transport' => 'postMessage'
            ),
            array(
                'id'    => 'subscribe_bg_image_type',
                'type'  => 'radio',
                'title' => esc_html__( 'Background image', 'seosight' ),
                'subtitle' => esc_html__( 'Select one of images or upload your own pattern', 'seosight' ),
                'options'    => array(
                    'predefined' => esc_html__( 'Predefined images', 'seosight' ),
                    'custom' => esc_html__( 'Custom image', 'seosight' ),
                ),
                'default' => seosight_get_unyson_option( 'custom-subscribe/yes/subscribe-show/yes/subscribe_bg_image/type', 'predefined', 'meta/' . $current_post_id )
            ),
            array(
                'id'    => 'subscribe_bg_image_predefined',
                'type'  => 'image_select',
                'title' => false,
                'options' => seosight_backgrounds(),
                'default' => seosight_get_unyson_option( 'custom-subscribe/yes/subscribe-show/yes/subscribe_bg_image/predefined', 'none', 'meta/' . $current_post_id ),
                'dependency' => array( 'subscribe_bg_image_type', '==', 'predefined' ),
            ),
            array(
                'id'    => 'subscribe_bg_image_custom',
                'type'  => 'upload',
                'library'  => 'image',
                'title' => false,
                'dependency' => array( 'subscribe_bg_image_type', '==', 'custom' ),
                'default' => seosight_get_unyson_option('custom-subscribe/yes/subscribe-show/yes/subscribe_bg_image/custom', '', 'meta/' . $current_post_id, 'background')
            ),
            array(
                'id'    => 'subscribe_bg_cover',
                'type'  => 'switcher',
                'title' => esc_html__( 'Expand background', 'seosight' ),
                'subtitle' => esc_html__( 'Don\'t repeat image and expand it to full section background', 'seosight' ),
                'default' => seosight_get_unyson_option( 'custom-subscribe/yes/subscribe-show/yes/subscribe_bg_cover', false, 'meta/' . $current_post_id ),
				'transport' => 'postMessage'
            ),
            array(
                'id'    => 'subscribe_animated',
                'type'  => 'switcher',
                'title' => esc_html__( 'Images animation', 'seosight' ),
                'subtitle' => esc_html__( 'Images animation when section become visible', 'seosight' ),
                'text_on' => esc_html__('Enable', 'seosight'),
                'text_off' => esc_html__('Disable', 'seosight'),
                'text_width' => 80,
                'default' => seosight_get_unyson_option( 'custom-subscribe/yes/subscribe-show/yes/subscribe_animated', false, 'meta/' . $current_post_id ),
            ),
            array(
                'id'    => 'section-subscribe-images',
                'type'  => 'fieldset',
                'title' => esc_html__( 'Customize Images', 'seosight' ),
                'fields' => array(
                    array(
                        'id'    => 'image_1',
                        'type'  => 'upload',
                        'library'  => 'image',
                        'title' => esc_html__( 'Image', 'seosight' ),
                        'subtitle' => esc_html__( 'Image that uprear from bottom', 'seosight' ),
                        'default' => seosight_get_unyson_option('custom-subscribe/yes/subscribe-show/yes/section-subscribe-images/image_1/url', '', 'meta/' . $current_post_id),
                    ),
                    array(
                        'id'    => 'image_2',
                        'type'  => 'upload',
                        'library'  => 'image',
                        'title' => esc_html__( 'Image', 'seosight' ),
                        'subtitle' => esc_html__( 'Image that uprear from right', 'seosight' ),
                        'default' => seosight_get_unyson_option('custom-subscribe/yes/subscribe-show/yes/section-subscribe-images/image_2/url', '', 'meta/' . $current_post_id),
                    ),
                    array(
                        'id'    => 'image_3',
                        'type'  => 'upload',
                        'library'  => 'image',
                        'title' => esc_html__( 'Image', 'seosight' ),
                        'subtitle' => esc_html__( 'Image that rotating', 'seosight' ),
                        'default' => seosight_get_unyson_option('custom-subscribe/yes/subscribe-show/yes/section-subscribe-images/image_3/url', '', 'meta/' . $current_post_id),
                    ),
                ),
            )
        );

        return $options;
    }

    // Metabox header
    public function metabox_header($current_post_id = 0){
        $options = array(
            array(
                'id'    => 'header-absolute',
                'type'  => 'switcher',
                'title' => esc_html__( 'Absolute placed Header', 'seosight' ),
                'subtitle' => esc_html__( 'Header will be placed over page content', 'seosight' ),
                'help' => esc_html__( 'Useful on pages with full-screen height sliders', 'seosight' ),
                'default' => seosight_get_unyson_option( 'custom-header/yes/header-absolute', false, 'meta/' . $current_post_id ),
            ),
            array(
                'id'    => 'header-opacity',
                'type'  => 'slider',
                'title' => esc_html__( 'Header opacity', 'seosight' ),
                'subtitle' => esc_html__( 'Make header background semitransparent', 'seosight' ),
                'help' => esc_html__( 'Useful on pages with full-screen height sliders', 'seosight' ),
                'default' => seosight_get_unyson_option( 'custom-header/yes/header-opacity', 100, 'meta/' . $current_post_id ),
                'min'     => 0,
                'max'     => 100,
                'step'    => 5,
            ),
            array(
                'id'    => 'header-color',
                'type'  => 'color',
                'title' => esc_html__( 'Text Color', 'seosight' ),
                'help'  => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
                'default' => seosight_get_unyson_option( 'custom-header/yes/header-color', '', 'meta/' . $current_post_id ),
            ),
            array(
                'id'    => 'select_menu',
                'type'  => 'select',
                'title'   => esc_html__( 'Select menu to display', 'seosight' ),
                'subtitle' => sprintf(__( 'Select one of website menus. Or <a href="%s">Create new menu</a>.', 'seosight' ), admin_url( 'nav-menus.php' ) ),
                'options' => seosight_get_menus(),
                'default' => seosight_get_unyson_option( 'custom-header/yes/select_menu', '', 'meta/' . $current_post_id ),
            )
        );

        return $options;
    }

    // Metabox stunning
    public function metabox_stunning($current_post_id = 0, $meta_type = 'meta'){
        $options = array(
            array(
                'id' => 'custom-title',
                'type'  => 'text',
                'title' => esc_html__( 'Custom title text', 'seosight' ),
                'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/custom-title', '', $meta_type . '/' . $current_post_id )
            ),
            array(
                'id'    => 'padding-top',
                'type'  => 'number',
                'title' => esc_html__( 'Padding top', 'seosight' ),
                'subtitle' => esc_html__( 'Number only', 'seosight' ),
                'default' => intval( seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/padding-top', '', $meta_type . '/' . $current_post_id ) )
            ),
            array(
                'id'    => 'padding-bottom',
                'type'  => 'number',
                'title' => esc_html__( 'Padding bottom', 'seosight' ),
                'subtitle' => esc_html__( 'Number only', 'seosight' ),
                'default' => intval( seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/padding-bottom', '', $meta_type . '/' . $current_post_id ) )
            ),
            array(
                'id'    => 'stunning_bg_type',
                'type'  => 'image_select',
                'title' => esc_html__( 'Type of background', 'seosight' ),
                'options' => array(
                    'image_bg' => get_template_directory_uri() . '/img/admin/image_bg.png',
                    'video_bg' => get_template_directory_uri() . '/img/admin/video_bg.png',
                ),
                'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/selected', 'image_bg', $meta_type . '/' . $current_post_id )
            ),
            array(
                'id'    => 'stunning_bg_image',
                'type'  => 'fieldset',
                'title' => false,
                'fields' => array(
                    array(
                        'id'    => 'stunning_bg_image_type',
                        'type'  => 'radio',
                        'title' => esc_html__( 'Background image', 'seosight' ),
                        'subtitle' => esc_html__( 'Select one of images or upload your own pattern', 'seosight' ),
                        'options'    => array(
                            'predefined' => esc_html__( 'Predefined images', 'seosight' ),
                            'custom' => esc_html__( 'Custom image', 'seosight' ),
                        ),
                        'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/image_bg/stunning_bg_image/type', 'predefined', $meta_type . '/' . $current_post_id )
                    ),
                    array(
                        'id'    => 'stunning_bg_image_predefined',
                        'type'  => 'image_select',
                        'title' => false,
                        'options' => seosight_backgrounds(),
                        'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/image_bg/stunning_bg_image/predefined', 'none', $meta_type . '/' . $current_post_id ),
                        'dependency' => array( 'stunning_bg_image_type', '==', 'predefined' ),
                    ),
                    array(
                        'id'    => 'stunning_bg_image_custom',
                        'type'  => 'upload',
                        'library'  => 'image',
                        'title' => false,
                        'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/image_bg/stunning_bg_image/custom', '', $meta_type . '/' . $current_post_id, 'background' ),
                        'dependency' => array( 'stunning_bg_image_type', '==', 'custom' ),
                    ),
                    array(
                        'id'    => 'stunning_bg_cover',
                        'type'  => 'switcher',
                        'title' => esc_html__( 'Expand background', 'seosight' ),
                        'subtitle'  => esc_html__( 'Don\'t repeat image and expand it to full section background', 'seosight' ),
                        'default' => ( seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/image_bg/stunning_bg_cover', '', $meta_type . '/' . $current_post_id ) == '1' ) ? true : false,
                    ),
                ),
                'dependency' => array( 'stunning_bg_type', '==', 'image_bg' ),
            ),
            array(
                'id'    => 'stunning_bg_video',
                'type'  => 'fieldset',
                'title' => false,
                'fields' => array(
                    array(
                        'id'    => 'placeholder',
                        'type'  => 'upload',
                        'title' => esc_html__( 'Placeholder Image', 'seosight' ),
                        'subtitle' => esc_html__( 'Please select placeholder image', 'seosight' ),
                        'library' => 'image',
                        'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/video_bg/placeholder/url', '', $meta_type . '/' . $current_post_id ),
                    ),
                    array(
                        'id'    => 'stunning_bg_cover',
                        'type'  => 'radio',
                        'title' => esc_html__( 'Video Source', 'seosight' ),
                        'options'    => array(
                            'oembed' => esc_html__('Youtube', 'seosight'),
                            'self' => esc_html__('Self hosted', 'seosight'),
                        ),
                        'inline' => true,
                        'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/video_bg/selected/source', 'oembed', $meta_type . '/' . $current_post_id ),
                    ),
                    array(
                        'id'    => 'stunning_bg_cover_oembed',
                        'type'  => 'text',
                        'title' => esc_html__( 'Video Link', 'seosight' ),
                        'subtitle'  => esc_html__( 'Insert Video URL to embed this video', 'seosight' ),
                        'dependency' => array( 'stunning_bg_cover', '==', 'oembed' ),
                        'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/video_bg/selected/oembed/source', '', $meta_type . '/' . $current_post_id ),
                    ),
                    array(
                        'id'    => 'stunning_bg_cover_self_mp4',
                        'type'  => 'upload',
                        'title' => esc_html__( 'Link to mp4 video', 'seosight' ),
                        'subtitle' => esc_html__( 'Source of uploaded video', 'seosight' ),
                        'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/video_bg/selected/self/mp4/url', '', $meta_type . '/' . $current_post_id ),
                        'dependency' => array( 'stunning_bg_cover', '==', 'self' ),
                    ),
                    array(
                        'id'    => 'stunning_bg_cover_self_webm',
                        'type'  => 'upload',
                        'title' => esc_html__( 'Link to webm video', 'seosight' ),
                        'subtitle' => esc_html__( 'Source of uploaded video', 'seosight' ),
                        'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/video_bg/selected/self/webm/url', '', $meta_type . '/' . $current_post_id ),
                        'dependency' => array( 'stunning_bg_cover', '==', 'self' ),
                    ),
                    array(
                        'id'    => 'stunning_bg_cover_self_ogg',
                        'type'  => 'upload',
                        'title' => esc_html__( 'Link to ogg video', 'seosight' ),
                        'subtitle' => esc_html__( 'Source of uploaded video', 'seosight' ),
                        'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/video_bg/selected/self/ogg/url', '', $meta_type . '/' . $current_post_id ),
                        'dependency' => array( 'stunning_bg_cover', '==', 'self' ),
                    ),
                ),
                'dependency' => array( 'stunning_bg_type', '==', 'video_bg' ),
            ),
            array(
                'id'    => 'stunning_overlay',
                'type'  => 'color',
                'title' => esc_html__( 'Color overlay', 'seosight' ),
                'subtitle' => esc_html__( 'Layer with colored overlay for background image', 'seosight' ),
                'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_overlay', '', $meta_type . '/' . $current_post_id ),
            ),
            array(
                'id'    => 'stunning_bg_color',
                'type'  => 'color',
                'title' => esc_html__( 'Background Color', 'seosight' ),
                'subtitle'  => esc_html__( 'If you choose no image to display - that color will be set as background', 'seosight' ),
                'help'  => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
                'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_bg_color', '#3e4d50', $meta_type . '/' . $current_post_id ),
            ),
            array(
                'id'    => 'stunning_text_color',
                'type'  => 'color',
                'title' => esc_html__( 'Text Color', 'seosight' ),
                'help'  => esc_html__( 'Click on field to choose color or clear field for default value', 'seosight' ),
                'default' => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_text_color', '', $meta_type . '/' . $current_post_id ),
            ),
            array(
                'id'    => 'stunning_hide_title',
                'type'  => 'radio',
                'default'   => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_hide_title', 'default', $meta_type . '/' . $current_post_id ),
                'title' => esc_html__( 'Hide title', 'seosight' ),
                'subtitle'  => esc_html__( 'Remove text with page title from stunning header section', 'seosight' ),
                'options' => array(
                    'default' => esc_html__( 'Default', 'seosight' ),
                    'no' => esc_html__( 'Show', 'seosight' ),
                    'yes' => esc_html__( 'Hide', 'seosight' ),
                ),
                'inline'  => true,
            ),
            array(
                'id'    => 'stunning_hide_breadcrumbs',
                'type'  => 'radio',
                'default'   => seosight_get_unyson_option( 'custom-stunning/yes/stunning-show/yes/stunning_hide_breadcrumbs', 'default', $meta_type . '/' . $current_post_id ),
                'title' => esc_html__( 'Hide breadcrumbs', 'seosight' ),
                'subtitle'  => esc_html__( 'Remove breadcrumbs from stunning header section', 'seosight' ),
                'options' => array(
                    'default' => esc_html__( 'Default', 'seosight' ),
                    'no' => esc_html__( 'Show', 'seosight' ),
                    'yes' => esc_html__( 'Hide', 'seosight' ),
                ),
                'inline'  => true,
            ),
        );
        return $options;
    }

    // Link field
    public function link($current_post_id = 0){
        $options = array(
				'id'        => 'link',
				'type'      => 'fieldset',
				'title'     => esc_html__( 'Set link', 'seosight' ),
				'fields'    => array(
                    array(
                        'id'    => 'source',
                        'type'  => 'select',
                        'title'   => esc_html__( 'Link source', 'seosight' ),
						'subtitle'    => esc_html__( 'Select link source', 'seosight' ),
						'options' => array(
							'url'  => esc_html__( 'Type url', 'seosight' ),
							'page' => esc_html__( 'Select page', 'seosight' ),
						),
                        'default' => seosight_get_unyson_option( 'project-button/link/selected/selected', '', 'meta/' . $current_post_id ),
                    ),
                    array(
                        'id'    => 'link',
                        'type'  => 'text',
                        'title' => esc_html__( 'Type Link', 'seosight' ),
                        'subtitle'  => esc_html__( 'Where should this element link to?', 'seosight' ),
                        'dependency' => array( 'source', '==', 'url' ),
                        'default' => seosight_get_unyson_option( 'project-button/link/selected/url/link', '', 'meta/' . $current_post_id ),
                    ),
                    array(
                        'id'    => 'page_link',
                        'type'  => 'select',
                        'title' => esc_html__( 'Select some blog page', 'seosight' ),
						'subtitle' => esc_html__( 'Select a page which this element will be linked to', 'seosight' ),
						'help'       => esc_html__( 'Click on field and type page name to find page', 'seosight' ),
                        'dependency' => array( 'source', '==', 'page' ),
                        'options'     => 'pages',
                        'query_args'  => array(
                            'posts_per_page' => -1 // for get all pages (also it's same for posts).
                        ),
                        'default' => seosight_get_unyson_option( 'project-button/link/selected/page/link/0', '', 'meta/' . $current_post_id ),
                    ),
                    array(
                        'id'    => 'target',
                        'type'  => 'switcher',
                        'title' => esc_html__( 'Open Link in New Window', 'seosight' ),
				        'subtitle'  => esc_html__( 'Select here if you want to open the linked page in a new window', 'seosight' ),
                        'text_on' => esc_html__('Yes', 'seosight'),
                        'text_off' => esc_html__('No', 'seosight'),
                        'text_width' => 60,
                        'default' => ( seosight_get_unyson_option( 'project-button/link/target', '', 'meta/' . $current_post_id ) == '_blank' ) ? true : false,
                    ),
                )
        );
        return $options;
    }
}

return new SeosightThemeOptionsFields();