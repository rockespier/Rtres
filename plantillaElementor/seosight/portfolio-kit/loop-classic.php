<?php
if ( ! defined( 'ABSPATH' ) ) {
	exit; // Exit if accessed directly.
}

$theKitClass = new PortfolioKit();

$permalink  = get_the_permalink();
$open_image = $theKitClass->get_option( get_post()->ID, 'portfolio_kit_page_behavior' );
$img_class  = '';
$img_wrap_class = 'pk-post-thumbnail case-item__thumb';
if ( $open_image == 'lightbox' ) {
	$permalink = get_the_post_thumbnail_url( get_post()->ID, 'full' );
	$img_class = 'pk-popup-image';
	$img_wrap_class = 'pk-post-thumbnail case-item__thumb pk-post-image-gallery';
}
$bg_color = ( $theKitClass->get_option( get_post()->ID, 'portfolio_kit_background' ) != '' ) ? 'background-color: ' . $theKitClass->get_option( get_post()->ID, 'portfolio_kit_background' ) . ';' : '';
$cat_list = get_the_term_list( get_post()->ID, 'portfolio-kit-cat', '', ', ' );
?>

<div class="pk-post-classic crumina-case-item mb30" <?php echo seosight_attr_to_html( array( 'style' => $bg_color ) ); ?>>
    <div class="<?php echo esc_attr($img_wrap_class ) ?>">
        <a href="<?php echo esc_url( $permalink ) ?>" class="<?php echo esc_attr( $img_class ); ?>">
			<?php echo get_the_post_thumbnail( get_post()->ID, 'medium_large' ); ?>
        </a>
    </div>
    <a href="<?php echo esc_url( $permalink ) ?>"
       class="pk-post-modern-title h5 case-item__title <?php echo esc_attr( $img_class ); ?>"><?php the_title(); ?></a>
	<?php if($cat_list){ ?>
        <div class="pk-post-modern-cats case-item__cat">
	        <?php seosight_render( $cat_list ); ?>
        </div>
	<?php } ?>
</div>