<?php

if ( !defined( 'ABSPATH' ) ) {
    die( 'Direct access forbidden.' );
}

/**
 * Set default Elementor options for the theme
 * Updated for Elementor 3.0+ compatibility
 */
function seosight_default_elementor_options() {

	// Add custom post types support
	$cpt_support = get_option( 'elementor_cpt_support' );

	// Check if option doesn't exist in db
	if( ! $cpt_support ) {
		$cpt_support = [ 'page', 'post', 'fw-portfolio' ]; // Create array of default supported post types
		update_option( 'elementor_cpt_support', $cpt_support );
	}
	// If it exists, but portfolio is not defined
	else if( ! in_array( 'fw-portfolio', $cpt_support ) ) {
		$cpt_support[] = 'fw-portfolio'; // Append to array
		update_option( 'elementor_cpt_support', $cpt_support );
	}

	// Disable default color schemes and typography schemes to allow theme styling
	update_option( 'elementor_disable_typography_schemes', 'yes' );
	update_option( 'elementor_disable_color_schemes', 'yes' );

	// Set preferred editor loader method (helps with loading issues)
	if ( get_option( 'elementor_editor_break_lines' ) === false ) {
		update_option( 'elementor_editor_break_lines', '1' );
	}

}
add_action( 'after_switch_theme', 'seosight_default_elementor_options' );
add_action( 'upgrader_process_complete', 'seosight_default_elementor_options', 10, 2);

function seosight_elementor_add_ref_links( $settings ){

	$settings = array_replace_recursive( $settings, [
		'icons'                => [
			'goProURL' => 'https://trk.elementor.com/3814',
		],
		'elementor_site'       => 'https://trk.elementor.com/3814',
		'docs_elementor_site'  => 'https://trk.elementor.com/3814',
		'help_the_content_url' => 'https://trk.elementor.com/3814',
		'help_right_click_url' => 'https://trk.elementor.com/3814',
		'help_flexbox_bc_url'  => 'https://trk.elementor.com/3814',
		'elementPromotionURL'  => 'https://trk.elementor.com/3814',
		'dynamicPromotionURL'  => 'https://trk.elementor.com/3814',
	] );

	return $settings;
};

add_filter( 'elementor/editor/localize_settings', 'seosight_elementor_add_ref_links' );

/**
 * Disable Google Fonts loading from Elementor (theme handles fonts)
 */
add_filter( 'elementor/frontend/print_google_fonts', '__return_false' );

/**
 * Fix potential script conflicts in Elementor editor
 * Prevent theme scripts from interfering with editor loading
 */
function seosight_elementor_editor_scripts() {
	// Safety check for Elementor Plugin instance
	if ( ! class_exists( '\Elementor\Plugin' ) ) {
		return;
	}

	// Check if we're in Elementor editor mode
	if ( ! \Elementor\Plugin::$instance->editor->is_edit_mode() ) {
		return;
	}

	// Ensure jQuery is loaded
	wp_enqueue_script( 'jquery' );
}
add_action( 'elementor/editor/before_enqueue_scripts', 'seosight_elementor_editor_scripts' );

/**
 * Improve Elementor editor compatibility
 * Add support for responsive editing and other modern features
 */
function seosight_elementor_compatibility() {
	// Enable improved CSS loading method
	if ( get_option( 'elementor_css_print_method' ) === false ) {
		update_option( 'elementor_css_print_method', 'internal' );
	}

	// Enable improved DOM optimization for better performance
	if ( get_option( 'elementor_optimized_dom_output' ) === false ) {
		update_option( 'elementor_optimized_dom_output', 'enabled' );
	}
}
add_action( 'elementor/loaded', 'seosight_elementor_compatibility' );

/**
 * Ensure Elementor assets are loaded properly in preview mode
 */
function seosight_elementor_preview_mode() {
	// Safety check for Elementor Plugin instance
	if ( ! class_exists( '\Elementor\Plugin' ) ) {
		return;
	}

	if ( \Elementor\Plugin::$instance->preview->is_preview_mode() ) {
		// Force load required assets for preview
		do_action( 'elementor/preview/enqueue_styles' );
	}
}
add_action( 'wp_enqueue_scripts', 'seosight_elementor_preview_mode', 999 );

/**
 * Disable theme preloader and potentially conflicting scripts in Elementor editor
 * This prevents loading screen issues in edit mode
 */
function seosight_elementor_disable_preloader( $preloader_enabled ) {
	// Safety check for Elementor Plugin instance
	if ( ! class_exists( '\Elementor\Plugin' ) ) {
		return $preloader_enabled;
	}

	// Disable preloader when in Elementor editor or preview mode
	if ( \Elementor\Plugin::$instance->editor->is_edit_mode() ||
	     \Elementor\Plugin::$instance->preview->is_preview_mode() ) {
		return false;
	}
	return $preloader_enabled;
}
add_filter( 'seosight_website_preloader', 'seosight_elementor_disable_preloader' );

/**
 * Dequeue potentially conflicting scripts in Elementor editor
 */
function seosight_elementor_dequeue_scripts() {
	// Safety check for Elementor Plugin instance
	if ( ! class_exists( '\Elementor\Plugin' ) ) {
		return;
	}

	// Check if we're in Elementor editor mode
	if ( ! \Elementor\Plugin::$instance->editor->is_edit_mode() ) {
		return;
	}

	// Dequeue custom inline scripts that might conflict
	// Keep only essential scripts for editing
	wp_dequeue_script( 'particles' );
	wp_dequeue_script( 'partical-animation' );
	wp_dequeue_script( 'scrollmagic' );
	wp_dequeue_script( 'scrollmagic-velocity' );
}
add_action( 'wp_enqueue_scripts', 'seosight_elementor_dequeue_scripts', 999 );
