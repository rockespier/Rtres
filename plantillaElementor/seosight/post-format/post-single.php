<?php
/**
 * Template part for displaying single posts.
 *
 * @link https://codex.wordpress.org/Template_Hierarchy
 *
 * @package Seosight
 */


$format = get_post_format();
if ( false === $format ) {
    $format = 'standard';
}

$show_stunning = get_query_var('show_stunning');

$show_featured  = seosight_get_option_value('single-featured-show', true, array('bool_val' => 'yes'));
$show_author    = seosight_get_option_value('single-author-show', true, array('bool_val' => 'yes'));
$show_meta      = seosight_get_option_value('single-meta-show', true, array('bool_val' => 'yes'));
$show_share     = seosight_get_option_value('single-share-show', true, array('bool_val' => 'yes'));
$show_related     = seosight_get_option_value('single-related-show', false, array('bool_val' => 'yes'));
$show_authorbox = seosight_get_option_value('author-box-show', true, array('bool_val' => 'yes'));
?>

<article id="post-<?php the_ID(); ?>" <?php post_class( 'post-standard-details' ); ?>>
    <?php if ( $show_featured ) : ?>
        <?php
        if ( 'video' === $format ) {
            $oembed = seosight_get_option_value('oembed', '', array('name' => 'video_oembed'), 'seosight_post_video', 'meta/' . get_the_ID() );
	        echo '<div class="post-thumb"><div class="embed-responsive embed-responsive-16by9">' . wp_oembed_get( $oembed, array(
			        'width'  => 1280,
			        'height' => 720
		        ) ) . '</div></div>';
        }
        if ( 'audio' === $format ) {
            $oembed = seosight_get_option_value('oembed', '', array('name' => 'audio_oembed'), 'seosight_post_audio', 'meta/' . get_the_ID() );
            echo '<div class="post-thumb">' . wp_oembed_get( $oembed, array(
                            'width'  => 750,
                            'height' => 180
                    ) ) . '</div>';
        } elseif ( 'standard' === $format && has_post_thumbnail() ) {
            echo '<div class="post-thumb">';
            the_post_thumbnail('seosight-full');
            echo '</div>';
        } ?>
    <?php endif; ?>
    <div class="post__content">
	    <?php if ( !$show_stunning ) {
		    the_title( '<h1 class="h2 entry-title">', '</h1>' );
	    } ?>
        <div class="post-additional-info">

            <?php if ( $show_author ) {
                seosight_post_author_avatar( get_the_author_meta( 'ID' ) );
            }
            if ( $show_meta ) {
                seosight_posted_on();
            } ?>

        </div>

        <div class="post__content-info">
            <div class="e-content entry-content">
                <?php the_content(); ?>
            </div>

            <?php wp_link_pages( array(
                    'before' => '<div class="page-links">' . esc_html__( 'Pages:', 'seosight' ),
                    'after'  => '</div>',
            ) ); ?>

            <?php seosight_entry_footer(); ?>

            <?php if ( $show_share ) { ?>
                <div class="socials">
                    <?php get_template_part( 'template-parts/share', 'icons' ); ?>
                </div>
            <?php } ?>
        </div>
    </div>
</article>
<?php if ( $show_authorbox ) {
    get_template_part( 'template-parts/author', 'box' );
}
if ($show_related){
	get_template_part( 'template-parts/related', 'posts' );
}