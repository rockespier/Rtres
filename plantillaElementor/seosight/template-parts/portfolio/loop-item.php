<?php
if ( !defined( 'FW' ) ) {
	die( 'Forbidden' );
}
$loop_data = get_query_var( 'fw_portfolio_loop_data' );


if ( null === $grid_size = get_query_var( 'portfolio-item-grid-size', null ) ) {
	$grid_size = seosight_get_option_value('width-columns', '4', array(), 'seosight_fw_portfolio_design_customize', 'meta/' . get_the_ID() );
}
$open_link = seosight_get_option_value('open-item', 'default', array(), 'seosight_fw_portfolio_page_open', 'meta/' . get_the_ID() );
$container_width = 1170;
$gap_paddings	 = 90;
$img_width		 = intval( $container_width / ( 12 / $grid_size ) ) - $gap_paddings;
$img_height		 = intval( $img_width * 0.75 );
$item_class_add	 = $grid_size > 5 ? 'big mb60' : 'mb30';
$title_tag		 = $grid_size > 5 ? 'h5' : 'h6';

$thumbnail_id = get_post_thumbnail_id();

if ( isset( $open_link ) && $open_link === 'lightbox' ) {
	$permalink	 = wp_get_attachment_image_src( $thumbnail_id, 'full' );
	$permalink	 = $permalink[ 0 ];
	$link_class	 = 'js-zoom-image';
} else {
	$permalink	 = get_the_permalink();
	$link_class	 = '';
}
?>

<div class="col-lg-<?php echo esc_attr( $grid_size ) ?> col-md-<?php echo esc_attr( $grid_size ) ?> col-sm-6 col-xs-12 sorting-item <?php echo (!empty( $loop_data[ 'listing_classes' ][ get_the_ID() ] ) ) ? $loop_data[ 'listing_classes' ][ get_the_ID() ] : ''; ?>">
    <div class="crumina-case-item align-center <?php echo esc_attr( $item_class_add ) ?>">
        <div class="crum-portfolio-item-mh">
			<div class="case-item__thumb mouseover lightbox shadow animation-disabled">
				<a href="<?php echo esc_url( $permalink ) ?>" class="<?php echo esc_attr( $link_class ) ?>">
					<?php
					$video = seosight_get_project_video();

					if ( $video ) {
						?>
						<div class="responsive-video">
							<?php seosight_render( $video ); ?>
						</div>
						<?php
					} else {
						$thumbnail_id = get_post_thumbnail_id();
						if ( !empty( $thumbnail_id ) ) {
							$thumbnail		 = get_post( $thumbnail_id );
							$url			 = wp_get_attachment_image_src( $thumbnail_id, 'full' );
							$image			 = seosight_resize( $url[ 0 ], $img_width, $img_height, true );
							$thumbnail_title = $thumbnail->post_title;
						} else {
							$image			 = fw()->extensions->get( 'portfolio' )->locate_URI( '/static/img/no-photo.jpg' );
							$thumbnail_title = $image;
						}
						?>
						<img loading="lazy" src="<?php echo esc_url( $image ) ?>" width="<?php echo esc_attr( $img_width ) ?>" height="<?php echo esc_attr( $img_height ) ?>" alt="<?php echo esc_attr( $thumbnail_title ) ?>"/>
					<?php } ?>
				</a>
			</div>
        </div>
        <a href="<?php echo esc_url( $permalink ) ?>"
           class="<?php echo esc_attr( $title_tag ) . ' ' . esc_attr( $link_class ) ?> case-item__title"><?php the_title(); ?></a>
		<?php the_terms( get_the_ID(), fw_akg( 'settings/taxonomy_name', $loop_data ), '<div class="case-item__cat">', ', ', '</div>' ); ?>
    </div>
</div>