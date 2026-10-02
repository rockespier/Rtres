<?php if ( ! defined( 'FW' ) ) {
	die( 'Forbidden' );
}

function seosight_fw_remove_portfolio_additional_image(){
	global $post;
	if ( use_block_editor_for_post( $post ) ) {
		remove_meta_box( 'postimagediv', 'fw-portfolio', 'side' );
	}

}

add_action( 'do_meta_boxes', 'seosight_fw_remove_portfolio_additional_image', 20 );
