<?php
/**
 * Template part for displaying posts.
 *
 * @link    https://codex.wordpress.org/Template_Hierarchy
 *
 * @package Seosight
 */
$post_gallery_images = seosight_get_option_value('gallery_images', array(), array('gallery' => true), 'seosight_post_gallery', 'meta/' . get_the_ID() );
$post_gallery_images = explode(",", $post_gallery_images);

$width                = 690;
$height               = 420;
$blog_grid_type       = get_query_var( 'blog_grid_type' );
$post_extra_classes   = get_query_var( 'post_extra_classes' );
$post_extra_classes   = is_array( $post_extra_classes ) ? $post_extra_classes : array();
$post_extra_classes[] = 'slider';

if ( is_sticky() ) {
    $post_extra_classes[] = 'sticky';
}
?>
<article id="post-<?php the_ID(); ?>" <?php post_class( implode( ' ', $post_extra_classes ) ); ?>>
    <?php if ( !empty( $post_gallery_images ) ) { ?>
        <div class="swiper-container post-standard-thumb-slider" data-autoplay="5000">
            <div class="swiper-wrapper">
                <?php
                foreach ( $post_gallery_images as $single_image ) {
                    $att_url = wp_get_attachment_url( $single_image );
					$url = seosight_resize( $att_url, $width, $height, true );
                    $alt = get_post_meta( $single_image, '_wp_attachment_image_alt', true );
                    ?>
                    <div class="post-thumb swiper-slide">
                        <?php echo seosight_html_tag( 'img', array( 'src' => $url, 'width' => $width, 'height' => $height, 'alt' => $alt ) ); ?>
                        <div class="overlay"></div>
                    </div>
                <?php } ?>
            </div>
            <!-- If we need pagination -->
            <div class="swiper-pagination"></div>
        </div>
    <?php } ?>

    <div class="post__content">
        <?php if ( empty( $post_gallery_images ) && $blog_grid_type === 'blog-grid-main' ) { ?>
            <div class="post__no_thumb"><img loading="lazy" src="<?php echo esc_url( get_template_directory_uri() . '/img/no-image.svg' ); ?>" alt="<?php esc_attr_e( 'No image', 'seosight' ); ?>"></div>
        <?php } ?>
        <div class="post__content-info">
            <?php seosight_grid_title_with_post_meta(); ?>

	        <?php
	        $excerpt = get_the_excerpt();
	        if ( ! has_excerpt() ) {
		        $excerpt = get_the_content();
	        } if ( !empty($excerpt) ){
		        ?>
                <div class="post__text">
                    <p><?php echo esc_html( wp_trim_words( $excerpt, 16 ) ); ?></p>
                </div>
	        <?php } ?>
        </div>

        <div class="post__author author vcard">
            <?php seosight_grid_post_author(); ?>
        </div>

        <?php
        wp_link_pages( array(
            'before' => '<div class="page-links">' . esc_html__( 'Pages:', 'seosight' ),
            'after'  => '</div>',
        ) );
        ?>
    </div>

</article>
