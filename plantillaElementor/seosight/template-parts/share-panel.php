<?php
$id      = get_the_ID();
$title   = get_the_title( $id );
$link    = get_permalink( $id );
$image   = get_the_post_thumbnail_url( $id, 'large' );
$caption = wp_trim_words( get_the_excerpt(), 20 );

$social_buttons = seosight_get_option_value( 'folio-social-buttons', array( 'facebook', 'twitter', 'linkedin', 'pinterest' ) );
if( !empty($social_buttons) ){
?>
<div class="socials-panel">
	<?php foreach( $social_buttons as $social_button ){ 
	$label = ucfirst($social_button);
	?>
	<div class="socials-panel-item <?php echo esc_attr($social_button); ?>-bg-color sharer" data-sharer="<?php echo esc_attr($social_button); ?>" data-url="<?php echo esc_attr( $link ) ?>">
		<div class="social__item">
			<i class="fa fa-<?php echo esc_attr($social_button); ?>"></i>
			<span class="social__item-text"><?php echo esc_html($label); ?></span>
		</div>
	</div>
	<?php } ?>
</div>
<?php } ?>