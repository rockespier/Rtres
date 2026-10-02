<?php

if ( !defined( 'ABSPATH' ) ) {
	die( 'Direct access forbidden.' );
}

//custom styles
add_action( 'wp_enqueue_scripts', 'seosight_custom_css_styles', 99 );
add_action( 'wp_enqueue_scripts', 'seosight_custom_font', 99 );

function seosight_generate_font_styles( $tag, $default = array('font-family' => 'Default', 'color' => '#2f2c2c') ){
	$typo_vals = seosight_get_option_value( 'typography_' . $tag, $default, array( 'typography' => true ) );
	if( $tag == 'nav' ){
		$font_css = 'header .navigation-menu li a{';
	} else {
		$font_css = $tag . ', .' . $tag . '{';
	}
	$font_family = (isset($typo_vals['font-family'])) ? $typo_vals['font-family'] : '';
	
	if ( !empty( $font_family ) && 'Default' !== $font_family ) {
		$font_css .= 'font-family:"' . $font_family . '", sans-serif;';
	}

	$font_color	 = (isset($typo_vals['color'])) ? $typo_vals['color'] : '';
	if ( !empty( $font_color ) ) {
		$font_css .= 'color:' . $font_color . ';';
	}
	$font_weight = (isset($typo_vals['font-weight'])) ? $typo_vals['font-weight'] : '';
	if ( !empty( $font_weight ) ) {
		$font_css .= 'font-weight:' . $font_weight . ';';
	}
	$font_style	 = (isset($typo_vals['font-style'])) ? $typo_vals['font-style'] : '';
	if ( !empty( $font_style ) ) {
		$font_css .= 'font-style:' . $font_style . ';';
	}
	$letter_spacing = (isset($typo_vals['letter-spacing'])) ? $typo_vals['letter-spacing'] : '';
	if ( !empty( $letter_spacing ) ) {
		$font_css .= 'letter-spacing:' . $letter_spacing . 'px;';
	}
	$size = (isset($typo_vals['font-size'])) ? $typo_vals['font-size'] : '';
	if ( !empty( $size ) ) {
		if ($tag === 'h1' || $tag === '.h1') {
			$min_size = $size/2;
			$fluid_value = $min_size/18 + 1;
			$font_css .= 'font-size:clamp(' . $min_size . 'px, calc(' . $fluid_value . 'vw + 1.2rem),'. $size . 'px);';
		} else if ($tag === 'h2' || $tag === '.h2') {
			$min_size = $size/1.9;
			$fluid_value = $min_size/18 + 1;
			$font_css .= 'font-size:clamp(' . $min_size . 'px, calc(' . $fluid_value . 'vw + 1rem),'. $size . 'px);';
		} else if ($tag === 'h3' || $tag === '.h3') {
			$min_size = $size/1.8;
			$fluid_value = $min_size/18;
			$font_css .= 'font-size:clamp(' . $min_size . 'px, calc(' . $fluid_value . 'vw + 1rem),'. $size . 'px);';
		} else if ($tag === 'h4' || $tag === '.h4') {
			$min_size = $size/1.6;
			$fluid_value = $min_size/18;
			$font_css .= 'font-size:clamp(' . $min_size . 'px, calc(' . $fluid_value . 'vw + 1rem),'. $size . 'px);';
		} else if ($tag === 'h5' || $tag === '.h5') {
			$min_size = $size/1.3;
			$fluid_value = $min_size/18;
			$font_css .= 'font-size:clamp(' . $min_size . 'px, calc(' . $fluid_value . 'vw + 1rem),'. $size . 'px);';
		} else {
			$font_css .= 'font-size:' . $size . 'px;';
		}
	}
	$text_transform = (isset($typo_vals['text-transform'])) ? $typo_vals['text-transform'] : '';
	if ( !empty( $text_transform ) ) {
		$font_css .= 'text-transform:' . $text_transform . ';';
	}

	$font_css .= '} ';

	if ( !empty( $font_color ) && $tag === 'nav' ) {
		$font_css .= "html:root {--header-font-color: {$font_color};} ";
	}

	return $font_css;
}

function seosight_custom_font() {
	$custom_css = '';

	$custom_css .= seosight_generate_font_styles( 'nav' );
	$custom_css .= seosight_generate_font_styles( 'logo' );
	$custom_css .= seosight_generate_font_styles( 'body', array(
		'font-family' => 'Default',
		'color' => '#7b7b7b'
	) );
	$custom_css .= seosight_generate_font_styles( 'h1' );
	$custom_css .= seosight_generate_font_styles( 'h2' );
	$custom_css .= seosight_generate_font_styles( 'h3' );
	$custom_css .= seosight_generate_font_styles( 'h4' );
	$custom_css .= seosight_generate_font_styles( 'h5' );
	$custom_css .= seosight_generate_font_styles( 'h6' );

	wp_add_inline_style( 'seosight-theme-style', $custom_css );
}

function seosight_custom_css_styles() {
	$custom_css		 = '';
	$website_preloader = seosight_get_option_value('website_preloader', false);

	// Allow Elementor and other plugins to disable the preloader
	$website_preloader = apply_filters( 'seosight_website_preloader', $website_preloader );

	if ( $website_preloader ) {
		if ( !empty( $primary_color ) ) {
			$bg_color = $primary_color;
		} else {
			$bg_color = '#4cc2c0';
		}
		$custom_css .= '#hellopreloader {display: block;position: fixed;z-index: 99999;top: 0;left: 0;width: 100%;height: 100%;min-width: 100%;background: url(' . get_template_directory_uri() . '/svg/preloader.svg) center center no-repeat;  background-color: ' . esc_attr( $bg_color ) . ';  background-size:100px;  opacity: 1;}';
	}

	// Paddings
	$sections_padding_picker = seosight_get_option_value( 'sections_padding/sections_padding_picker', 'medium' );
	switch ( $sections_padding_picker ) {
		case 'small':
			$padding_top	 = 40;
			$padding_bottom	 = 40;
				break;
		case 'medium':
			$padding_top	 = 80;
			$padding_bottom	 = 80;
				break;
		case 'large':
			$padding_top	 = 120;
			$padding_bottom	 = 120;
				break;
		default:
			$padding_top	 = (int) seosight_get_option_value( 'sections_padding/custom/top', 120 );
			$padding_bottom	 = (int) seosight_get_option_value( 'sections_padding/custom/bottom', 120 );
				break;
	}

	if ( is_int( $padding_top ) && is_int( $padding_bottom ) ) {
		$custom_css .= ".elementor-section:not(.elementor-inner-section) , .kc_row:not(.kc_row_inner) , .medium-padding120 {padding: {$padding_top}px 0 {$padding_bottom}px;}";
	}

	$header_bg_color = seosight_get_option_value( 'header_bg_color', '#ffffff' );
	if ('#ffffff' != $header_bg_color){
		$custom_css .= '#site-header, #site-header .navigation-megamenu, #site-header li:not(.mega-menu-col)>.navigation-dropdown, #site-header .navigation-body{background-color:' . esc_attr( $header_bg_color ) . ';} ';
	}

	// Logo font size
	$logo_title_fz = seosight_get_option_value( 'typography_logo_title_fz', '' );
	if ($logo_title_fz != ''){
		$custom_css .= '.logo .logo-text .logo-title{font-size:' . esc_attr( $logo_title_fz ) . 'px;} ';
	}

	$logo_desc_fz = seosight_get_option_value( 'typography_logo_descr_fz', '' );
	if ($logo_desc_fz != ''){
		$custom_css .= '.logo .logo-text .logo-sub-title{font-size:' . esc_attr( $logo_desc_fz ) . 'px;} ';
	}

	// Subscribe section
	$subscribe_bg = $subscribe_bg_img = $subscribe_text = $subscribe_css = '';
	$subscribe_section = seosight_get_option_value( 'show_subscribe_section', true, array('bool_val' => 'yes') );
	if($subscribe_section){
		$subscribe_bg		 = seosight_get_option_value( 'subscribe_bg_color', '' );
		$subscribe_bg_img_type = seosight_get_option_value( 'subscribe_bg_image_type', 'predefined', array('name' => 'subscribe_bg_image/type') );
		$subscribe_bg_img = '';
		if( $subscribe_bg_img_type == 'predefined' ){
			$subscribe_bg_img_pr = seosight_get_option_value( 'subscribe_bg_image_predefined', 'none', array('name' => 'subscribe_bg_image/predefined') );
			if( $subscribe_bg_img_pr != 'none' ){
				$subscribe_bg_img = 'background-image: url("' . get_template_directory_uri() . '/images/' . $subscribe_bg_img_pr . '.png' . '");';
			}
		} else {
			$subscribe_bg_img_cust = seosight_get_option_value( 'subscribe_bg_image_custom', '', array('name' => 'subscribe_bg_image/custom', 'background' => true) );
			$subscribe_bg_img = 'background-image: url("' . $subscribe_bg_img_cust . '");';
		}
		$subscribe_bg_cover	 = seosight_get_option_value( 'subscribe_bg_cover', false );
		$subscribe_text		 = seosight_get_option_value( 'subscribe_text_color', '' );
	}

	$current_page_id = get_the_ID();
	if (function_exists('wc_get_page_id')){
		$shop_page_id = wc_get_page_id('shop');
		$page_id = is_shop() || is_product() || is_product_taxonomy() ? $shop_page_id : $current_page_id;
	} else {
		$page_id = $current_page_id;
	}

	$enable_customization = seosight_get_option_value('custom-subscribe-enable', false, array('name' => 'custom-subscribe/enable', 'bool_val' => 'yes'), 'seosight_design_options', 'meta/' . $page_id );
	$subscribe_section = seosight_get_option_value('subscribe-show', true, array('name' => 'custom-subscribe/yes/subscribe-show/value', 'bool_val' => 'yes'), 'seosight_design_options', 'meta/' . $page_id );
	if ( $subscribe_section && $enable_customization) {
		$subscribe_bg		 = seosight_get_option_value('custom-subscribe/subscribe_bg_color', '', array('name' => 'custom-subscribe/yes/subscribe-show/yes/subscribe_bg_color' ), 'seosight_design_options', 'meta/' . $page_id );
		$subscribe_bg_cover	 = seosight_get_option_value('custom-subscribe/subscribe_bg_cover', false, array('name' => 'custom-subscribe/yes/subscribe-show/yes/subscribe_bg_cover' ), 'seosight_design_options', 'meta/' . $page_id );
		$subscribe_text		 = seosight_get_option_value('custom-subscribe/subscribe_text_color', '', array('name' => 'custom-subscribe/yes/subscribe-show/yes/subscribe_text_color' ), 'seosight_design_options', 'meta/' . $page_id );
	
		$subscribe_bg_img_type = seosight_get_option_value( 'custom-subscribe/subscribe_bg_image_type', 'predefined', array('name' => 'custom-subscribe/yes/subscribe-show/yes/subscribe_bg_image/type'), 'seosight_design_options', 'meta/' . $page_id );
		if( $subscribe_bg_img_type == 'predefined' ){
			$subscribe_bg_img_pr = seosight_get_option_value( 'custom-subscribe/subscribe_bg_image_predefined', 'none', array('name' => 'custom-subscribe/yes/subscribe-show/yes/subscribe_bg_image/predefined'), 'seosight_design_options', 'meta/' . $page_id );
			if( $subscribe_bg_img_pr != 'none' ){
				$subscribe_bg_img = 'background-image: url("' . get_template_directory_uri() . '/images/' . $subscribe_bg_img_pr . '.png' . '");';
			}
		} else {
			$subscribe_bg_img_cust = seosight_get_option_value( 'custom-subscribe/subscribe_bg_image_custom', '', array('name' => 'custom-subscribe/yes/subscribe-show/yes/subscribe_bg_image/custom', 'background' => true), 'seosight_design_options', 'meta/' . $page_id );
			$subscribe_bg_img = 'background-image: url("' . $subscribe_bg_img_cust . '");';
		}
	}

	if ( !empty( $subscribe_bg_img ) ) {
		$subscribe_css .= $subscribe_bg_img . ';';
		if ( $subscribe_bg_cover ) {
			$subscribe_css .= 'background-size:cover;';
		}
	}

	if ( !empty( $subscribe_bg ) || !empty( $subscribe_text ) || !empty( $subscribe_css ) ) {
		$custom_css .= '#subscribe-section{';
		$custom_css .= $subscribe_css;
		if ( !empty( $subscribe_bg ) ) {
			$custom_css .= 'background-color:' . esc_attr( $subscribe_bg ) . ';';
		}
		if ( !empty( $subscribe_text ) ) {
			$custom_css .= 'color:' . esc_attr( $subscribe_text ) . ';';
		}
		$custom_css .= '} ';
	}

	// Footer section styling.
	$footer_bg		 = seosight_get_option_value( 'footer_bg_color', '' );
	if( function_exists('fw_get_db_customizer_option') ){
		$footer_bg_img	 = fw_get_db_customizer_option( 'footer_bg_image', '' );
	} else {
		$footer_bg_img_type = seosight_get_option_value( 'footer_bg_image_type', 'predefined', array('name' => 'footer_bg_image/type') );
		$footer_bg_img = '';
		if( $footer_bg_img_type == 'predefined' ){
			$footer_bg_img_pr = seosight_get_option_value( 'footer_bg_image_predefined', 'none', array('name' => 'footer_bg_image/predefined') );
			if( $footer_bg_img_pr != 'none' ){
				$footer_bg_img = 'background-image: url("' . get_template_directory_uri() . '/images/' . $footer_bg_img_pr . '.png' . '")';
			}
		} else {
			$footer_bg_img_cust = seosight_get_option_value( 'footer_bg_image_custom', '', array('name' => 'footer_bg_image/custom', 'background' => true) );
			$footer_bg_img = 'background-image: url("' . $footer_bg_img_cust . '")';
		}
	}
	$footer_bg_cover = seosight_get_option_value( 'footer_bg_cover', false );
	$footer_text	 = seosight_get_option_value( 'footer_text_color', '' );
	$footer_title	 = seosight_get_option_value( 'footer_title_color', '' );

	if ( !empty( $footer_bg ) || !empty( $footer_bg_img ) || !empty( $footer_text ) ) {
		$custom_css .= '#site-footer{';
		if ( !empty( $footer_bg ) ) {
			$custom_css .= 'background-color:' . esc_attr( $footer_bg ) . ';';
		}
		if( function_exists('fw_get_db_customizer_option') ){
			if ( !empty( $footer_bg_img ) ) {
				$bg_img_url = fw_akg( 'data/css/background-image', $footer_bg_img, '' );
				if ( isset( $footer_bg_img ) && !empty( $footer_bg_img ) ) {
					$custom_css .= 'background-image:' . ( $bg_img_url ) . ';';

					if ( $footer_bg_cover ) {
						$custom_css .= 'background-size:cover;';
					}
				}
			}
		} else {
			if ( !empty( $footer_bg_img ) ) {
				$custom_css .= $footer_bg_img . ';';
				if ( $footer_bg_cover ) {
					$custom_css .= 'background-size:cover;';
				}
			}
		}
		if ( !empty( $footer_text ) ) {
			$custom_css .= 'color:' . esc_attr( $footer_text ) . ';';
		}
		$custom_css .= '}';
	}
	if ( !empty( $footer_title ) ) {
		$custom_css	 .= '.footer .info .heading .heading-title, #site-footer .contacts-item .content .title, #site-footer a, .footer .info .crumina-heading .heading-title{';
		$custom_css	 .= 'color:' . esc_attr( $footer_title ) . ';';
		$custom_css	 .= '}';
	}

	$copyright_bg	 = seosight_get_option_value( 'copyright_bg_color', '' );
	$copyright_text	 = seosight_get_option_value( 'copyright_text_color', '' );
	if ( !empty( $copyright_bg ) || !empty( $copyright_text ) ) {
		if ( !empty( $copyright_bg ) ) {
			$custom_css .= '#site-footer .sub-footer{ background-color:' . esc_attr( $copyright_bg ) . '}';
		}
		if ( !empty( $copyright_text ) ) {
			$custom_css .= '#site-footer .site-copyright-text{ color:' . esc_attr( $copyright_text ) . '}';
		}
	}

	// Stunning header
	$style_stunning = '';

	$stunning_bg_color = seosight_get_option_value( 'stunning_bg_color', '' );
	$stunning_text_color = seosight_get_option_value( 'stunning_text_color', '' );
	$stunning_padding_top = seosight_get_option_value( 'stunning-padding/padding-top', '', array('name' => 'stunning-show/yes/padding-top') );
	$stunning_padding_bottom = seosight_get_option_value( 'stunning-padding/padding-bottom', '', array('name' => 'stunning-show/yes/padding-bottom') );
	$stunning_bg_image_type = seosight_get_option_value( 'stunning_bg_image/stunning_bg_image_type', 'predefined' );
	$stunning_bg_image = '';
	if( $stunning_bg_image_type == 'predefined' ){
		$stunning_bg_image_pr = seosight_get_option_value( 'stunning_bg_image/stunning_bg_image_predefined', 'none', array('name' => 'stunning_bg_type/image_bg/stunning_bg_image/predefined') );
		if( $stunning_bg_image_pr != 'none' ){
			$stunning_bg_image = 'background-image: url("' . get_template_directory_uri() . '/images/' . $stunning_bg_image_pr . '.png' . '");';
		}
	} else {
		$stunning_bg_image_cust = seosight_get_option_value( 'stunning_bg_image/stunning_bg_image_custom', '', array('name' => 'stunning_bg_type/image_bg/stunning_bg_image/custom', 'background' => true) );
		$stunning_bg_image = 'background-image: url("' . $stunning_bg_image_cust . '");';
	}

	$stunning_bg_cover = seosight_get_option_value( 'stunning_bg_image/stunning_bg_cover', false, array('name' => 'stunning_bg_type/image_bg/stunning_bg_cover') );

	$stunning_meta_type = 'meta';
	$stunning_page_id = $page_id;
	$stunning_source = 'seosight_design_options';
	if ( is_singular( 'fw-portfolio' ) || is_singular( 'portfolio-kit' ) ) {
		$stunning_source = 'seosight_fw_portfolio_design_customize';
	}
	$queried_object = get_queried_object();
	if ( is_category() || (is_tax() && 'fw-portfolio-category' === $queried_object->taxonomy) ) {
		$stunning_meta_type = 'termmeta';
		$stunning_page_id = $queried_object->term_id;
		$stunning_source = 'seosight_category';
	}
	$enable_customization = seosight_get_option_value( 'custom-stunning-enable', false, array('name'=>'custom-stunning/enable', 'bool_val' => 'yes'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
	if ( $enable_customization ) {
		$meta_bg_color = seosight_get_option_value( 'custom-stunning/stunning_bg_color', '', array('name'=>'custom-stunning/yes/stunning-show/yes/stunning_bg_color'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
		$meta_bg_cover = seosight_get_option_value( 'custom-stunning/stunning_bg_image/stunning_bg_cover', false, array('name'=>'custom-stunning/yes/stunning-show/yes/stunning_bg_type/image_bg/stunning_bg_cover'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
		$meta_text_color = seosight_get_option_value( 'custom-stunning/stunning_text_color', '', array('name'=>'custom-stunning/yes/stunning-show/yes/stunning_text_color'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );

		$stunning_bg_color	 = !empty( $meta_bg_color ) ? $meta_bg_color : $stunning_bg_color;
		$stunning_bg_cover	 = !empty( $meta_bg_cover ) ? $meta_bg_cover : $stunning_bg_cover;
		$stunning_text_color	 = !empty( $meta_text_color ) ? $meta_text_color : $stunning_text_color;

		$stunning_bg_image_type = seosight_get_option_value( 'custom-stunning/stunning_bg_image/stunning_bg_image_type', 'predefined',  array('name'=>'custom-stunning/yes/stunning-show/yes/stunning_bg_type/image_bg/stunning_bg_image/type'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
		if( $stunning_bg_image_type == 'predefined' ){
			$stunning_bg_image_pr = seosight_get_option_value( 'custom-stunning/stunning_bg_image/stunning_bg_image_predefined', 'none', array('name' => 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/image_bg/stunning_bg_image/predefined'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
			if( $stunning_bg_image_pr != 'none' ){
				$stunning_bg_image = 'background-image: url("' . get_template_directory_uri() . '/images/' . $stunning_bg_image_pr . '.png' . '");';
			}
		} else {
			$stunning_bg_image_cust = seosight_get_option_value( 'custom-stunning/stunning_bg_image/stunning_bg_image_custom', '', array('name' => 'custom-stunning/yes/stunning-show/yes/stunning_bg_type/image_bg/stunning_bg_image/custom', 'background' => true), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
			$stunning_bg_image = 'background-image: url("' . $stunning_bg_image_cust . '");';
		}

		$stunning_padding_bottom = seosight_get_option_value( 'custom-stunning/padding-bottom', intval($stunning_padding_bottom), array('name' => 'custom-stunning/yes/stunning-show/yes/padding-bottom'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
		$stunning_padding_top = seosight_get_option_value( 'custom-stunning/padding-top', intval($stunning_padding_top), array('name' => 'custom-stunning/yes/stunning-show/yes/padding-top'), $stunning_source, $stunning_meta_type . '/' . $stunning_page_id );
	}

	if ( !empty($stunning_padding_top) ) {
		$style_stunning .= 'padding-top:' . intval($stunning_padding_top) . 'px;';
	}
	if ( !empty($stunning_padding_bottom) ) {
		$style_stunning .= 'padding-bottom:' . intval($stunning_padding_bottom) . 'px;';
	}
	if ( !empty( $stunning_bg_color ) ) {
		$style_stunning .= 'background-color:' . ( $stunning_bg_color ) . ';';
	}
	if ( !empty( $stunning_bg_image ) ) {
		$style_stunning .= $stunning_bg_image;
	}
	if ( $stunning_bg_cover ) {
		$style_stunning .= 'background-size:cover;';
	}
	if ( !empty( $stunning_text_color ) ) {
		$style_stunning .= 'color:' . ( $stunning_text_color ) . ';';
	}

	if ( !empty( $style_stunning ) ) {
		$custom_css .= '#stunning-header{' . $style_stunning . '}';
	}

	$primary_color	 = get_option( 'primary-accent-color' );
	$primary_color	 = $primary_color !== false ? $primary_color : get_theme_mod( 'primary_color', '' );

	$secondary_color = get_option( 'secondary-accent-color' );
	$secondary_color = $secondary_color !== false ? $secondary_color : get_theme_mod( 'secondary_color', '' );

	$links_color	 = get_option( 'links-color' );

	if ( ! empty( $links_color ) || ! empty( $secondary_color ) || ! empty( $primary_color ) ) {
		$custom_css .= ':root{';
		if ( ! empty( $primary_color ) ) {
			$custom_css .= '--primary-accent-color: ' . esc_attr( $primary_color ) . ';';
		}
		if ( ! empty( $secondary_color ) ) {
			$custom_css .= '--secondary-accent-color: ' . esc_attr( $secondary_color ) . ';';
		}
		if ( ! empty( $links_color ) ) {
			$custom_css .= '--global-link-color: ' . esc_attr( $links_color ) . ';';
		}
		$custom_css .= '}';
	}

	if ( is_page() || is_singular( 'fw-portfolio' ) || is_singular( 'portfolio-kit' ) || is_singular( 'post' ) ) {
		$customize_design_single = 'seosight_design_options';
		if ( is_singular( 'fw-portfolio' ) || is_singular( 'portfolio-kit' ) ) {
			$customize_design_single = 'seosight_fw_portfolio_design_customize';
		}

		$enable_customization = seosight_get_option_value( 'custom-header-enable', false, array('name'=>'custom-header/enable', 'bool_val' => 'yes'), $customize_design_single, 'meta/' . $page_id );
		if( $enable_customization ){
			$header_opacity = seosight_get_option_value( 'custom-header/header-opacity', '100', array('name'=>'custom-header/yes/header-opacity'), $customize_design_single, 'meta/' . $page_id );
 			$font_color = seosight_get_option_value( 'custom-header/header-color', '', array('name'=>'custom-header/yes/header-color'), $customize_design_single, 'meta/' . $page_id );
			if ( 100 != $header_opacity || !empty( $font_color ) ) {
				$custom_css .= '#site-header{';
				if ( 100 != $header_opacity ) {
					$custom_css .= 'background:rgba(255,255,255,0.' . esc_attr( $header_opacity ) . ');';
				}
				if ( !empty( $font_color ) ) {
					$custom_css .= 'color:' . esc_attr( $font_color ) . ';';
				}
				$custom_css .= '}';
				if ( 100 != $header_opacity ) {
					$custom_css .= '@media (min-width: 992px){#site-header .navigation-body{background:transparent};}';
				}
				if ( !empty( $font_color ) ) {
					$custom_css .= '#site-header .navigation-menu ul.navigation-dropdown li > a, #site-header .navigation-menu li a, .sub-menu-has-icons a .menu-item-icon, .megamenu-item-info-text, .megamenu-item-info-title{color:' . esc_attr( $font_color ) . ';}';
				}
			}
		}
	}

	wp_add_inline_style( 'seosight-theme-blocks', $custom_css );
}