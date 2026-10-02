<?php
/**
 * Template part for displaying posts.
 *
 * @link https://codex.wordpress.org/Template_Hierarchy
 *
 * @package Seosight
 */
$oembed = seosight_get_option_value('oembed', '', array('name' => 'audio_oembed'), 'seosight_post_audio', 'meta/' . get_the_ID() );

$post_extra_classes   = get_query_var( 'post_extra_classes' );
$post_extra_classes   = is_array( $post_extra_classes ) ? $post_extra_classes : array();

if ( is_sticky() ) {
    $post_extra_classes[] = 'sticky';
}
?>

<article id="post-<?php the_ID(); ?>" <?php post_class( implode( ' ', $post_extra_classes ) ); ?>>

    <?php if ( !empty( $oembed ) ) { ?>
        <div class="post-thumb">
            <?php
            echo wp_oembed_get( $oembed, array( 'width' => 690, 'height' => 180 ) );
            ?>
        </div>
    <?php } ?>

    <div class="post__content">
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