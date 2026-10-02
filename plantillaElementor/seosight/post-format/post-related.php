<?php
/**
 * Template part for displaying posts.
 *
 * @link https://codex.wordpress.org/Template_Hierarchy
 *
 * @package Seosight
 */
?>

<article id="post-<?php the_ID(); ?>" <?php post_class( 'post-standard post--grid-masonry post--grid related' ); ?>>


        <div class="post-thumb-wrap">
            <div class="post-thumb">
                <a href="<?php the_permalink(); ?>">
	                <?php if ( get_the_post_thumbnail() ) {
	                    the_post_thumbnail( 'post-thumbnails' );
	                } else { ?>
                        <img loading="lazy" src="<?php echo esc_url( get_template_directory_uri() . '/img/no-image.png' ); ?>" alt="<?php esc_attr_e( 'No image', 'seosight' ); ?>" width="360" height="225">
                    <?php } ?>
                </a>
            </div>
        </div>
    <div class="post__content">
	    <?php the_title('<h4 class="post__title entry-title">','</h4>'); ?>
    </div>

</article>