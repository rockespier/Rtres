<?php if ( ! defined( 'ABSPATH' ) ) { die( 'Direct access forbidden.' ); }

/**
 * Set up the content width value based on the theme's design.
 *
 * @see _action_seosight_content_width()
 */

if ( ! isset( $GLOBALS[ 'content_width' ] ) ) {
	$GLOBALS[ 'content_width' ] = 810;
}

/**
 * Adjust content_width value for image attachment template.
 * @internal
 */

function seosight_adjust_content_width() {
	global $content_width;

	if ( is_home() || is_archive() ) {
		$content_width = 568;
	} elseif ( is_page() ) {
		$content_width = 1170;
	} elseif ( is_attachment() && wp_attachment_is_image() ) {
		$GLOBALS[ 'content_width' ] = 810;
	}


}
add_action( 'template_redirect', 'seosight_adjust_content_width' );