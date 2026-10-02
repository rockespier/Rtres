<?php
	$theme_style = seosight_get_option_value( 'sections-top-bar/theme-style', 'top-bar-dark', array('name' => 'sections-top-bar/show/theme-style') );
	$show_languages = seosight_get_option_value( 'sections-top-bar/show-languages', false, array('name' => 'sections-top-bar/show/show-languages/status', 'bool_val' => 'show') );
	$language_select = seosight_get_option_value( 'sections-top-bar/language-select', 'theme-select', array('name' => 'sections-top-bar/show/show-languages/show/language-select/status') );
	$language_shortcode = seosight_get_option_value( 'sections-top-bar/shortcode', '', array('name' => 'sections-top-bar/show/show-languages/show/language-select/plugin-select/shortcode') );
	$info_boxes = seosight_get_option_value( 'sections-top-bar/info-boxes', array(array('info' => 'info@seosight.com')), array('name' => 'sections-top-bar/show/info-boxes') );
	$default_social = array(
		array(
			'link' => 'https://www.facebook.com/',
			'icon' => 'facebook.svg',
		),
		array(
			'link' => 'https://www.youtube.com/',
			'icon' => 'youtube.svg',
		),
		array(
			'link' => 'https://twitter.com',
			'icon' => 'twitter.svg',
		),
	);
	$social_networks = seosight_get_option_value( 'sections-top-bar/social-networks', $default_social, array('name' => 'sections-top-bar/show/social-networks') );
	$show_login = seosight_get_option_value( 'sections-top-bar/show-login', false, array('name' => 'sections-top-bar/show/show-login/status', 'bool_val' => 'show') );
	?>
    <div class="top-bar <?php echo esc_attr($theme_style); ?>">
        <div class="container">
			<div class="top-bar-content-wrapper">
				<?php if ( $show_languages && ( $language_select == 'plugin-select' ) ) {
					echo do_shortcode( $language_shortcode );
				} ?>
				<div class="top-bar-contact">
					<?php
					if ( $show_languages 
						 && ( $language_select != 'plugin-select' )
						 && ( function_exists( 'icl_get_languages' ) )
					) {
						$top_bar_lang = icl_get_languages( 'skip_missing=0&orderby=code' );
						$active_languages     = ( isset( $top_bar_lang ) && ! empty( $top_bar_lang ) ) ? $top_bar_lang : array();
						$lang_img             = '';
						$active_lang_key      = '';
						$lang_options_str     = '';
						foreach ( $active_languages as $lang_key => $lang_conf ) {
							if ( $lang_conf['active'] ) {
								$lang_img        = $lang_conf['country_flag_url'];
								$active_lang_key = $lang_key;
							}
							$lang_options_str .= '<option data-url="' . $lang_conf['url'] . '" value="' . $lang_key . '"'
												 . ( ( $lang_key == $active_lang_key ) ? 'selected="selected"' : '' )
												 . '>' . $lang_conf['native_name'] . '</option>';
						}
						?>
						<div class="contact-item">
							<img loading="lazy" src="<?php echo esc_attr($lang_img); ?>" class="flags" alt="flags">
							<select id="top-bar-language" class="nice-select">
								<?php seosight_render($lang_options_str); ?>
							</select>
						</div>
					<?php } ?>
					<?php
					if ( ! empty( $info_boxes ) ) {
					foreach ( $info_boxes as $infoField ) { ?>
						<div class="contact-item">
							<?php
							$field = $infoField['info'];
							if ( seosight_is_phone( $field ) ) {
								echo "<a href=\"tel:$field\">$field</a>";
							} elseif ( seosight_is_email( $field ) ) {
								echo "<a href=\"mailto:$field\">$field</a>";
							} else {
								echo wp_kses( $field, wp_kses_allowed_html( $field ) );
							}
							?>

						</div>

					<?php } } ?>

				</div>

				<?php if ( ! empty( $social_networks ) ) { ?>
					<div class="follow_us">
						<span><?php esc_html_e( 'Follow us:', 'seosight' ); ?></span>
						<div class="socials">
							<?php foreach ( $social_networks as $social ) { ?>
								<a href="<?php echo esc_html( $social['link'] ); ?>" target="_blank" class="social__item" rel="nofollow">
									<img src="<?php echo esc_url( get_template_directory_uri() . '/svg/socials/' . $social[ 'icon' ] ); ?>" alt="<?php echo esc_attr( ucfirst( trim( $social[ 'icon' ], '.svg' ) ) ); ?>">
								</a>
							<?php } ?>
						</div>
					</div>
				<?php } ?>

				<?php if ( $show_login ): ?>
					<div class="login-block">
						<?php
						if ( is_user_logged_in() ) {
							global $current_user;
							echo get_avatar( $current_user->user_email, 28, '', '', array( 'class' => 'sign-in' ) ); ?>
							<a href="<?php echo wp_logout_url(); ?>"><?php esc_html_e( 'Sign out', 'seosight' ); ?></a>
						<?php } else { ?>
							<img src="<?php echo esc_url( get_template_directory_uri() . '/img/signin_dark.png' ); ?>" class="sign-in">
							<a href="<?php echo wp_login_url(); ?>"><?php esc_html_e( 'Sign in', 'seosight' ); ?></a>
						<?php } ?>
					</div>
				<?php endif; ?>
				<i class="top-bar-close">
					<span></span>
					<span></span>
				</i>
			</div>
        </div>
    </div>