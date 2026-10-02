<?php

if ( ! defined( 'ABSPATH' ) ) {
	die( 'Direct access forbidden.' );
}
/**
 * Settings and options for online preview Customizer changes.
 *
 * @package Seosight
 */
global $wp_customize;

/**
 * @param WP_Customize_Manager $wp_customize
 *
 * @internal
 */
function _action_customizer_live_crum_options( $wp_customize ) {
	//Color options
	$wp_customize->add_setting( 'primary-accent-color', array(
		'type'              => 'option',
		'default'           => '#4cc2c0',
		'capability'        => 'manage_options',
		'sanitize_callback' => 'sanitize_hex_color',
	) );

	$wp_customize->add_control( 'primary-accent-color', array(
		'label'    => esc_html__( 'Primary Accent Color', 'seosight' ),
		'section'  => 'colors',
		'type'     => 'color',
		'settings' => 'primary-accent-color',
	) );

	$wp_customize->add_setting( 'secondary-accent-color', array(
		'type'              => 'option',
		'default'           => '#f15b26',
		'capability'        => 'manage_options',
		'sanitize_callback' => 'sanitize_hex_color',
	) );

	$wp_customize->add_control( 'secondary-accent-color', array(
		'label'    => esc_html__( 'Secondary Accent Color', 'seosight' ),
		'section'  => 'colors',
		'type'     => 'color',
		'settings' => 'secondary-accent-color',
	) );

	$wp_customize->add_setting( 'links-color', array(
		'type'              => 'option',
		'default'           => '#2f2c2c',
		'capability'        => 'manage_options',
		'sanitize_callback' => 'sanitize_hex_color',
	) );

	$wp_customize->add_control( 'links-color', array(
		'label'    => esc_html__( 'Links Color', 'seosight' ),
		'section'  => 'colors',
		'type'     => 'color',
		'settings' => 'links-color',
	) );
}

add_action( 'customize_register', '_action_customizer_live_crum_options' );

/**
 * @internal
 */
function _action_customizer_live_crum_options_preview() {
	$my_theme          = wp_get_theme();
	$theme_version     = $my_theme->get( 'Version' );
	$translation_array = array( 'templateUrl' => get_template_directory_uri() );
	wp_enqueue_script(
		'seosight-customizer',
		get_template_directory_uri() . '/js/customizer.js',
		array( 'jquery', 'customize-preview' ),
		$theme_version,
		true
	);
	wp_localize_script( 'seosight-customizer', 'theme_vars', $translation_array );
}

add_action( 'customize_preview_init', '_action_customizer_live_crum_options_preview' );