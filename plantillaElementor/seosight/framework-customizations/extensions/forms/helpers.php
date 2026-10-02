<?php if ( ! defined( 'FW' ) ) {
 	die( 'Forbidden' );
}

add_action( 'admin_footer', '_action_seosight_enable_fw_forms' );
function _action_seosight_enable_fw_forms() {
	if ( fw()->extensions->manager->can_activate() ) {
		fw()->extensions->manager->activate_extensions( array( 'forms' => array(), 'builder' => array() ) );
	}
}

add_action( 'updated_post_meta', '_action_seosight_cpt_form_save', 0, 4 );
function _action_seosight_cpt_form_save() {
	global $post;
	if ( ! empty( $post ) && $post->post_type == 'crum-form' ) {
		$form_meta = get_post_meta( $post->ID, 'fw_options', true );
		if ( ! empty( $form_meta ) ) {
			update_option( 'fw:ext:cf:fd:' . $post->ID, $form_meta );
		}
	}
}

add_action( 'trashed_post', '_action_seosight_cpt_form_delete' );
function _action_seosight_cpt_form_delete( $post_id ) {
	if ( 'crum-form' == get_post_type( $post_id ) ) {
		delete_option( 'fw:ext:cf:fd:' . $post_id );
	}
}

add_action( 'admin_enqueue_scripts', 'seosight_forms_admin_enqueue_scripts', 100 );
function seosight_forms_admin_enqueue_scripts() {
	wp_dequeue_script( 'fw-builder-form-builder-item-recaptcha' );
	wp_enqueue_script(
			'fw-builder-form-builder-item-recaptcha-seosight',
			get_template_directory_uri() . "/framework-customizations/extensions/forms/form-builder/items/recaptcha/static/js/scripts.js",
			array(
				'fw-events',
				'fw',
			),
			false,
			true
	);
}