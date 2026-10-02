<?php if (!defined('FW')) die('Forbidden');

/**
 * @var WP_Post $item
 * @var string $title
 * @var array $attributes
 * @var object $args
 * @var int $depth
 * @var string $item_arrow_icon
 */


if ( fw()->extensions->get( 'megamenu' )->show_icon() ) {
    $parsed = get_post_meta($item->ID, 'seosight_menu_icon', true);
	if( is_array($parsed) ){
		$icon = array_merge( array(
			'icon_type' => '',
			'icon_class' => '',
			'icon_url' => ''
		), $parsed );
	} else {
		$icon = array(
			'icon_type' => '',
			'icon_class' => '',
			'icon_url' => ''
		);
	}

    if ( $icon[ 'icon_type' ] === 'custom-upload' && !empty( $icon[ 'icon_url' ] ) ) {
        $title = seosight_html_tag( 'img', array(
            'class' => 'menu-item-icon menu-item-icon-img',
            'src'   => $icon[ 'icon_url' ],
            'alt'   => 'Menu item img icon'
        ), false ) . $title;
    }

    if ( $icon[ 'icon_type' ] === 'icon-font' && !empty( $icon[ 'icon_class' ] ) ) {
        $title = seosight_html_tag( 'i', array( 'class' => 'menu-item-icon ' . $icon[ 'icon_class' ] ), true ) . $title;
    }
}

seosight_render($args->before);


/*If empty link in item - we will print title item instead link*/
$mega_opt = get_post_meta($item->ID, 'seosight_menu_options', true);
$mega_title_column_item = (isset($mega_opt['title_column_item'])) ? $mega_opt['title_column_item'] : false;
if (
	( empty( $attributes['href'] ) || $attributes['href'] === 'http://' || $attributes['href'] === 'http://#' || $attributes['href'] === 'https://' || $attributes['href'] === 'https://#' ) ||
	($depth === 1) && $mega_title_column_item ) {
	echo '<div class="megamenu-item-info">';
	$mega_fields_hide_title = (isset($mega_opt['hide-title'])) ? $mega_opt['hide-title'] : false;
	if ($depth > 0 && !$mega_fields_hide_title) {
		echo seosight_html_tag( 'div', array( 'class' => 'h6 megamenu-item-info-title' ), $title );
	}
	if ( ! empty( $item->description ) ) {
		echo seosight_html_tag( 'div', array( 'class' => 'megamenu-item-info-text' ),  do_shortcode( $item->post_content ) );
	}
	echo '</div>';
} else {
	$mega_fields_hide_title = (isset($mega_opt['hide-title'])) ? $mega_opt['hide-title'] : false;
	if ($depth !== 0){
		$title .= seosight_html_tag( 'i', array( 'class' => $item_arrow_icon ), true );
	}
	if ($depth > 0 && $mega_fields_hide_title) {
		echo seosight_html_tag('a', $attributes, $args->link_before . $title . $args->link_after);
		if ( ! empty( trim( $item->description ) ) ) {
			echo seosight_html_tag( 'div', array( 'class' => 'megamenu-item-info-text' ), do_shortcode( $item->post_content ) );
		}
	} else {
		echo seosight_html_tag('a', $attributes, $args->link_before . $title . $args->link_after);
	}
}
seosight_render($args->after);
