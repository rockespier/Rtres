<?php
// if ( ! defined( 'FW' ) ) {
// 	return;
// }
/**
 * Template part for displaying Subscribe panel before footer.
 *
 * You free to customize widget contents in child theme.
 * Copy that file into 'template-parts' folder of your Child Theme.
 *
 * @package Seosight
 */
wp_enqueue_script( 'scrollmagic-velocity' );

global $allowedtags;

$show_section    = seosight_get_option_value( 'show_subscribe_section', true, array('bool_val' => 'yes') );
$animated_bg     = seosight_get_option_value( 'subscribe_animated', false );
$section_bg      = seosight_get_option_value( 'subscribe_bg_color', '' );
$section_color   = seosight_get_option_value( 'subscribe_text_color', '' );

$animated_image_1 = seosight_get_option_value('section-subscribe-images/image_1', '', array('name' => 'section-subscribe-images/image_1/url'));
$animated_image_2 = seosight_get_option_value('section-subscribe-images/image_2', '', array('name' => 'section-subscribe-images/image_2/url'));
$animated_image_3 = seosight_get_option_value('section-subscribe-images/image_3', '', array('name' => 'section-subscribe-images/image_3/url'));
if ( empty( $animated_image_1 ) ) {
	$animated_image_1 = get_template_directory_uri() . '/images/animated/subscr1.png';
}
if ( empty( $animated_image_2 ) ) {
	$animated_image_2 = get_template_directory_uri() . '/images/animated/subscr-mailopen.png';
}
if ( empty( $animated_image_3 ) ) {
	$animated_image_3 = get_template_directory_uri() . '/images/animated/subscr-gear.png';
}
$title            = seosight_get_option_value('section-subscribe-form/title');
$lists            = seosight_get_option_value('section-subscribe-form/list');
$text             = seosight_get_option_value('section-subscribe-form/desc');

$enable_email_subscribers_pl = false;
if ( function_exists( 'es_subbox' ) ) {
    $enable_email_subscribers_pl = true;
}
$enable_email_subscribers = seosight_get_option_value('section-subscribe-form/enable_email_subscribers', $enable_email_subscribers_pl);

$custom_form_html = seosight_get_option_value('section-subscribe-form/custom_form_html', '', array('name' => 'section-subscribe-form/custom-form/yes/html'));
$name_field_show  = seosight_get_option_value('section-subscribe-form/show_form_name_field', false, array('name' => 'section-subscribe-form/custom-form/no/name_field/show', 'bool_val' => '1'));
$name_field_swap  = seosight_get_option_value('section-subscribe-form/show_form_name_field_swap', false, array('name' => 'section-subscribe-form/custom-form/no/name_field/true/name_field_swap', 'bool_val' => '1'));

$enable_customization = seosight_get_option_value('custom-subscribe-enable', false, array('name' => 'custom-subscribe/enable', 'bool_val' => 'yes'), 'seosight_design_options', 'meta/' . get_the_ID()  );
if ( $enable_customization ) {
	$show_section = seosight_get_option_value('subscribe-show', true, array('name' => 'custom-subscribe/yes/subscribe-show/value', 'bool_val' => 'yes'), 'seosight_design_options', 'meta/' . get_the_ID() );
	$animated_bg = seosight_get_option_value('custom-subscribe/subscribe_animated', false, array('name' => 'custom-subscribe/yes/subscribe-show/yes/subscribe_animated'), 'seosight_design_options', 'meta/' . get_the_ID() );

	$animated_image_1_c = seosight_get_option_value('custom-subscribe/section-subscribe-images/image_1', '', array('name' => 'custom-subscribe/yes/subscribe-show/yes/section-subscribe-images/image_1/url'), 'seosight_design_options', 'meta/' . get_the_ID() );
	$animated_image_2_c = seosight_get_option_value('custom-subscribe/section-subscribe-images/image_2', '', array('name' => 'custom-subscribe/yes/subscribe-show/yes/section-subscribe-images/image_2/url'), 'seosight_design_options', 'meta/' . get_the_ID() );
	$animated_image_3_c = seosight_get_option_value('custom-subscribe/section-subscribe-images/image_3', '', array('name' => 'custom-subscribe/yes/subscribe-show/yes/section-subscribe-images/image_3/url'), 'seosight_design_options', 'meta/' . get_the_ID() );

	if( $animated_image_1_c != '' ){
		$animated_image_1 = $animated_image_1_c;
	}
	if( $animated_image_2_c != '' ){
		$animated_image_2 = $animated_image_2_c;
	}
	if( $animated_image_3_c != '' ){
		$animated_image_3 = $animated_image_3_c;
	}
}

if ( !$show_section ) {
	return;
}

$section_class = array( 'subscribe-section' );
if ( ! empty( $section_color ) ) {
	$section_class[] = 'font-color-custom';
}

$subscribe_class   = array();
$subscribe_class[] = ( $name_field_show ) ? 'form-subscribe with-name subscribe-form es_subscription_form es_shortcode_form' : 'es_subscription_form form-subscribe subscribe-form es_shortcode_form';
$email_placeholder = ( $name_field_show ) ? __( 'Email', 'seosight' ) : __( 'Your Email Address', 'seosight' );

if ( $animated_bg ) {
	$section_class[] = 'js-animated';
}

if ( $name_field_swap ) {
	$subscribe_class[] = 'name-field-swap';
}
?>
<!-- Subscribe Form -->
<section id="subscribe-section" class="<?php echo implode( ' ', $section_class ) ?>">
    <div class="subscribe container">
        <div class="row">
            <div class="col-lg-6 col-lg-offset-5 col-md-12 col-md-offset-0 col-sm-12 col-xs-12">
				<?php
				if ( ! empty( $title ) ) {
					echo '<h4 class="subscribe-title">' . esc_html( $title ) . '</h4>';
				}

				if ( ! $enable_email_subscribers && ! empty( $custom_form_html ) ) {
					echo( do_shortcode( $custom_form_html ) );
				} elseif ( function_exists( 'es_subbox' ) && $enable_email_subscribers ) {
					$current_page     = get_the_ID();
					$current_page_url = get_the_permalink( get_the_ID() );

					$unique_id = time();

					$hp_style = "position:absolute;top:-99999px;" . ( is_rtl() ? 'right' : 'left' ) . ":-99999px;z-index:-99;";
					$nonce    = wp_create_nonce( 'es-subscribe' );

					global $es_includes;
					if ( ! isset( $es_includes ) || $es_includes !== true ) {
						$es_includes = true;
					}

					// Compatibility for GDPR
					$active_plugins = get_option( 'active_plugins', array() );
					if ( is_multisite() ) {
						$active_plugins = array_merge( $active_plugins, get_site_option( 'active_sitewide_plugins', array() ) );
					}
					if ( ! empty( $lists ) && ! is_string( $lists ) ) {
						$rand = rand( 111, 999 );
						?>
                        <form action="#" method="post" class="<?php echo implode( ' ', $subscribe_class ) ?>"
                              id="es_subscription_form_<?php echo esc_attr( $unique_id ); ?>" data-source="ig-es">
							<?php $name_field_html = ''; ?>
							<?php $email_field_html = ''; ?>

							<?php foreach ( $lists as $l ) { ?>
                                <input type="hidden" name="lists[]" value="<?php echo esc_attr( $l ); ?>">
							<?php } ?>

							<?php ob_start(); ?>
                            <input type="email" required="required" id="es_txt_email_pg" class="es_textbox_class"
                                   name="email" maxlength="40"
                                   placeholder="<?php echo esc_html( $email_placeholder ) ?>">
							<?php $email_field_html = ob_get_clean(); ?>

							<?php
							if ( $name_field_show ) {
								ob_start();
								?>
                                <input type="text" required="required" id="es_txt_name_pg"
                                       class="es_textbox_class name input-standard-grey input-white" name="name"
                                       value="" maxlength="40" placeholder="<?php esc_attr_e( 'Name', 'seosight' ); ?>">
								<?php
								$name_field_html = ob_get_clean();
							}
							?>

							<?php 
							if($name_field_swap){
								echo '' . $name_field_html . $email_field_html;
							} else {
								echo '' . $email_field_html . $name_field_html; 
							}
							?>

                            <label style="<?php seosight_render( $hp_style ); ?>"><input type="email" name="es_hp_email"
                                                                           class="es_required_field" tabindex="-1"
                                                                           autocomplete="-1" value=""/></label>
							<?php do_action( 'ig_es_after_form_fields' ) ?>
							<?php if ( ( in_array( 'gdpr/gdpr.php', $active_plugins ) || array_key_exists( 'gdpr/gdpr.php', $active_plugins ) ) ) {
								echo GDPR::consent_checkboxes();
							} ?>
                            <button type="submit" name="submit"
                                    class="es_subscription_form_submit es_submit_button subscr-btn"
                                    id="es_subscription_form_submit_<?php echo esc_attr( $unique_id ); ?>">
								<?php esc_html_e( 'Subscribe', 'seosight' ) ?>
                                <span class="semicircle--right"></span>
                            </button>

							<?php if ( !$name_field_show ) { ?>
                                <input type="hidden" id="es_txt_name_pg" name="es_txt_name_pg" value="">
								<?php
							}
							?>

                            <input type="hidden" name="es-subscribe" id="es-subscribe"
                                   value="<?php seosight_render( $nonce ); ?>"/>
                            <input type="hidden" name="es_email_page" value="<?php echo esc_attr( $current_page ); ?>"/>
                            <input type="hidden" name="es_email_page_url"
                                   value="<?php echo esc_url( $current_page_url ); ?>"/>
                            <input type="hidden" name="status" value="Unconfirmed"/>
                            <label style="<?php seosight_render( $hp_style ); ?>"><input type="text"
                                                                                         name="es_hp_<?php echo wp_create_nonce( 'es_hp' ); ?>"
                                                                                         class="es_required_field"
                                                                                         tabindex="-1"
                                                                                         autocomplete="off"/></label>
                            <div class="flex-break"></div>
                        </form>
                        <span class="es_subscription_message"
                              id="es_subscription_message_<?php echo esc_attr( $unique_id ); ?>"></span>
					<?php } else {
						?>
                        <p class="error"><?php esc_html_e( 'You should select subscription list in your builder component', 'seosight' ) ?></p>
					<?php }
					?>
					<?php
				}
				if ( ! empty( $text ) ) {
					echo '<div class="sub-title">' . wp_kses( $text, $allowedtags ) . '</div>';
				}
				?>
            </div>
			<?php $images_class = $animated_bg ? 'images-block' : 'images-block not-animated'; ?>
            <div class="<?php echo esc_attr( $images_class ); ?>">
                <img loading="lazy" src="<?php echo esc_url( $animated_image_3 ) ?>" width="58" height="57" alt="gear" class="gear">
                <img loading="lazy" src="<?php echo esc_url( $animated_image_1 ) ?>" width="470" height="290" alt="mail" class="mail">
                <img loading="lazy" src="<?php echo esc_url( $animated_image_2 ) ?>" width="138" height="133" alt="mailopen" class="mail-2">
            </div>
        </div>
    </div>
</section>
<!-- End Subscribe Form -->
