<?php
if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}
$links = paginate_links( array(
    'base'      => str_replace('%_%', 1 == $the_query->get( 'paged' ) ? '' : $format, $format),
    'format'    => $format,
    'total'     => $the_query->max_num_pages,
    'current'   => $the_query->get( 'paged' ),
    'mid_size'  => 3,
    'prev_next' => true,
    'prev_text' => '<svg class="btn-prev"><use xlink:href="#arrow-left"></use></svg>',
	'next_text' => '<svg class="btn-next"><use xlink:href="#arrow-right"></use></svg>',
) );

if ( !$links ) {
    return '';
}

seosight_render( $links );