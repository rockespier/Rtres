<?php
/**
 * Template part for displaying posts.
 *
 * @link    https://codex.wordpress.org/Template_Hierarchy
 *
 * @package Seosight
 */
$post_gallery_images = seosight_get_option_value('gallery_images', '', array('gallery' => true), 'seosight_post_gallery', 'meta/' . get_the_ID() );
$post_gallery_images = explode(",", $post_gallery_images);
$width  = 690;
$height = 420;
$show_excerpt = get_query_var( 'post_excerpt', false );
?>
<article id="post-<?php the_ID(); ?>" <?php post_class( 'post-standard slider' ); ?>>
	<?php if ( ! empty( $post_gallery_images ) ) { ?>
		<div class="swiper-container post-standard-thumb-slider" data-autoplay="5000">
			<div class="swiper-wrapper">
				<?php foreach ( $post_gallery_images as $single_image ) {
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

		<?php seosight_post_author_avatar( get_the_author_meta( 'ID' ) ) ?>

		<div class="post__content-info">

			<?php the_title( '<h2 class="post__title entry-title"><a href="' . esc_url( get_permalink() ) . '" rel="bookmark">', '</a></h2>' ); ?>

			<div class="post-additional-info">
				<?php seosight_posted_on(); ?>
			</div>

			<div class="post__text">
                <?php
                if ( $show_excerpt ) {
                    the_excerpt();
                } else {
                    if ( ! has_excerpt() ) {
                        the_content();
                    } else {
                        the_excerpt();
                    }
                } ?>
			</div>

			<?php
			wp_link_pages( array(
				'before' => '<div class="page-links">' . esc_html__( 'Pages:', 'seosight' ),
				'after'  => '</div>',
			) );
			?>

		</div>
	</div>

</article>
