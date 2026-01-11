<template>
  <form @submit.prevent="onSubmit">
    <section class="settings">
      <b-loading :is-full-page="true" v-if="loading.settings || isLoading" active />
      <header class="columns page-header">
        <div class="column is-half">
          <h1 class="title is-4">
            {{ $t('settings.title') }}
            <span class="has-text-grey-light">({{ serverConfig.version }})</span>
          </h1>
        </div>
        <div class="column has-text-right">
          <b-field v-if="$can('settings:manage')" expanded>
            <b-button expanded :disabled="!hasFormChanged" type="is-primary" icon-left="content-save-outline"
              native-type="submit" class="isSaveEnabled" data-cy="btn-save">
              {{ $t('globals.buttons.save') }}
            </b-button>
          </b-field>
        </div>
      </header>
      <hr />

      <section class="wrap settings-container" v-if="form">
        <b-tabs position="is-left" :animated="false" v-model="tab" class="settings-tabs" vertical>
          <b-tab-item v-if="$isVisible('settings.general')" :label="$getLabel('settings.general', $t('settings.general.name'))">
            <general-settings :form="form" :key="key" />
          </b-tab-item><!-- general -->

          <b-tab-item v-if="$isVisible('settings.performance')" :label="$getLabel('settings.performance', $t('settings.performance.name'))">
            <performance-settings :form="form" :key="key" />
          </b-tab-item><!-- performance -->

          <b-tab-item v-if="$isVisible('settings.privacy')" :label="$getLabel('settings.privacy', $t('settings.privacy.name'))">
            <privacy-settings :form="form" :key="key" />
          </b-tab-item><!-- privacy -->

          <b-tab-item v-if="$isVisible('settings.security')" :label="$getLabel('settings.security', $t('settings.security.name'))">
            <security-settings :form="form" :key="key" />
          </b-tab-item><!-- security -->

          <b-tab-item v-if="$isVisible('settings.media')" :label="$getLabel('settings.media', $t('settings.media.title'))">
            <media-settings :form="form" :key="key" />
          </b-tab-item><!-- media -->

          <b-tab-item v-if="$isVisible('settings.smtp')" :label="$getLabel('settings.smtp', $t('settings.smtp.name'))">
            <smtp-settings :form="form" :key="key" />
          </b-tab-item><!-- mail servers -->

          <b-tab-item v-if="$isVisible('settings.api')" :label="$getLabel('settings.api', $t('settings.api.name'))">
            <api-settings :form="form" :key="key" />
          </b-tab-item><!-- api -->

          <b-tab-item v-if="$isVisible('settings.bounces')" :label="$getLabel('settings.bounces', $t('settings.bounces.name'))">
            <bounce-settings :form="form" :key="key" />
          </b-tab-item><!-- bounces -->

          <b-tab-item v-if="$isVisible('settings.messengers')" :label="$getLabel('settings.messengers', $t('settings.messengers.name'))">
            <messenger-settings :form="form" :key="key" />
          </b-tab-item><!-- messengers -->

          <b-tab-item v-if="$isVisible('settings.appearance')" :label="$getLabel('settings.appearance', $t('settings.appearance.name'))">
            <appearance-settings :form="form" :key="key" />
          </b-tab-item><!-- appearance -->
        </b-tabs>
      </section>
    </section>
  </form>
</template>

<script>
import Vue from 'vue';
import { mapState } from 'vuex';
import AppearanceSettings from './settings/appearance.vue';
import BounceSettings from './settings/bounces.vue';
import GeneralSettings from './settings/general.vue';
import MediaSettings from './settings/media.vue';
import MessengerSettings from './settings/messengers.vue';
import PerformanceSettings from './settings/performance.vue';
import ApiSettings from './settings/api.vue';
import PrivacySettings from './settings/privacy.vue';
import SecuritySettings from './settings/security.vue';
import SmtpSettings from './settings/smtp.vue';

export default Vue.extend({
  components: {
    GeneralSettings,
    PerformanceSettings,
    PrivacySettings,
    SecuritySettings,
    MediaSettings,
    SmtpSettings,
    ApiSettings,
    BounceSettings,
    MessengerSettings,
    AppearanceSettings,
  },

  data() {
    return {
      // :key="key" is a ack to re-render child components every time settings
      // is pulled. Otherwise, props don't react.
      key: 0,

      isLoading: false,

      // formCopy is a stringified copy of the original settings against which
      // form is compared to detect changes.
      formCopy: '',
      form: null,
      tab: 0,
    };
  },

  methods: {
    async onSubmit() {
      const form = JSON.parse(JSON.stringify(this.form));

      // SMTP boxes.
      let hasDummy = '';
      for (let i = 0; i < form.smtp.length; i += 1) {
        // trim the host before saving
        form.smtp[i].host = form.smtp[i].host?.trim();

        // If it's the dummy UI password placeholder, ignore it.
        if (this.isDummy(form.smtp[i].password)) {
          form.smtp[i].password = '';
        } else if (this.hasDummy(form.smtp[i].password)) {
          hasDummy = `smtp #${i + 1}`;
        }

        if (form.smtp[i].strEmailHeaders && form.smtp[i].strEmailHeaders !== '[]') {
          form.smtp[i].email_headers = JSON.parse(form.smtp[i].strEmailHeaders);
        } else {
          form.smtp[i].email_headers = [];
        }
      }

      // Bounces boxes.
      for (let i = 0; i < form['bounce.mailboxes'].length; i += 1) {
        // trim the host before saving
        form['bounce.mailboxes'][i].host = form['bounce.mailboxes'][i].host?.trim();

        // If it's the dummy UI password placeholder, ignore it.
        if (this.isDummy(form['bounce.mailboxes'][i].password)) {
          form['bounce.mailboxes'][i].password = '';
        } else if (this.hasDummy(form['bounce.mailboxes'][i].password)) {
          hasDummy = `bounce #${i + 1}`;
        }
      }

      if (this.isDummy(form['upload.s3.aws_secret_access_key'])) {
        form['upload.s3.aws_secret_access_key'] = '';
      } else if (this.hasDummy(form['upload.s3.aws_secret_access_key'])) {
        hasDummy = 's3';
      }

      if (this.isDummy(form['bounce.sendgrid_key'])) {
        form['bounce.sendgrid_key'] = '';
      } else if (this.hasDummy(form['bounce.sendgrid_key'])) {
        hasDummy = 'sendgrid';
      }

      if (this.isDummy(form['security.captcha'].hcaptcha.secret)) {
        form['security.captcha'].hcaptcha.secret = '';
      } else if (this.hasDummy(form['security.captcha'].hcaptcha.secret)) {
        hasDummy = 'captcha';
      }

      if (this.isDummy(form['security.oidc'].client_secret)) {
        form['security.oidc'].client_secret = '';
      } else if (this.hasDummy(form['security.oidc'].client_secret)) {
        hasDummy = 'oidc';
      }

      if (this.isDummy(form['bounce.postmark'].password)) {
        form['bounce.postmark'].password = '';
      } else if (this.hasDummy(form['bounce.postmark'].password)) {
        hasDummy = 'postmark';
      }

      if (this.isDummy(form['bounce.forwardemail'].key)) {
        form['bounce.forwardemail'].key = '';
      } else if (this.hasDummy(form['bounce.forwardemail'].key)) {
        hasDummy = 'forwardemail';
      }

      if (this.isDummy(form.postal.api_key)) {
        form.postal.api_key = '';
      } else if (this.hasDummy(form.postal.api_key)) {
        hasDummy = 'postal';
      }

      if (this.isDummy(form.postal.webhook_secret)) {
        form.postal.webhook_secret = '';
      } else if (this.hasDummy(form.postal.webhook_secret)) {
        hasDummy = 'postal';
      }

      if (this.isDummy(form.sendgrid.api_key)) {
        form.sendgrid.api_key = '';
      } else if (this.hasDummy(form.sendgrid.api_key)) {
        hasDummy = 'sendgrid';
      }

      if (this.isDummy(form.mailgun.api_key)) {
        form.mailgun.api_key = '';
      } else if (this.hasDummy(form.mailgun.api_key)) {
        hasDummy = 'mailgun';
      }

      for (let i = 0; i < form.messengers.length; i += 1) {
        // If it's the dummy UI password placeholder, ignore it.
        if (this.isDummy(form.messengers[i].password)) {
          form.messengers[i].password = '';
        } else if (this.hasDummy(form.messengers[i].password)) {
          hasDummy = `messenger #${i + 1}`;
        }
      }

      if (hasDummy) {
        this.$utils.toast(this.$t('globals.messages.passwordChangeFull', { name: hasDummy }), 'is-danger');
        return false;
      }

      // Domain blocklist array from multi-line strings.
      form['privacy.domain_blocklist'] = form['privacy.domain_blocklist'].split('\n').map((v) => v.trim().toLowerCase()).filter((v) => v !== '');
      form['privacy.domain_allowlist'] = form['privacy.domain_allowlist'].split('\n').map((v) => v.trim().toLowerCase()).filter((v) => v !== '');

      this.isLoading = true;
      try {
        const data = await this.$api.updateSettings(form);
        await this.$root.awaitRestart(data);
        this.getSettings();
      } finally {
        this.isLoading = false;
      }

      return false;
    },

    getSettings() {
      this.isLoading = true;
      this.$api.getSettings().then((data) => {
        let d = {};
        try {
          // Create a deep-copy of the settings hierarchy.
          d = JSON.parse(JSON.stringify(data));
        } catch (err) {
          return;
        }

        // Serialize the `email_headers` array map to display on the form.
        for (let i = 0; i < d.smtp.length; i += 1) {
          d.smtp[i].strEmailHeaders = JSON.stringify(d.smtp[i].email_headers, null, 4);
        }

        // Domain blocklist array to multi-line string.
        d['privacy.domain_blocklist'] = d['privacy.domain_blocklist'].join('\n');
        d['privacy.domain_allowlist'] = d['privacy.domain_allowlist'].join('\n');

        this.key += 1;
        this.form = d;
        this.formCopy = JSON.stringify(d);

        this.$nextTick(() => {
          this.isLoading = false;
        });
      });
    },

    isDummy(pwd) {
      return !pwd || (pwd.match(/•/g) || []).length === pwd.length;
    },

    hasDummy(pwd) {
      return pwd.includes('•');
    },
  },

  computed: {
    ...mapState(['serverConfig', 'loading']),

    hasFormChanged() {
      if (!this.formCopy) {
        return false;
      }
      return JSON.stringify(this.form) !== this.formCopy;
    },
  },

  beforeRouteLeave(to, from, next) {
    if (this.hasFormChanged) {
      this.$utils.confirm(this.$t('globals.messages.confirmDiscard'), () => next(true));
      return;
    }
    next(true);
  },

  mounted() {
    this.tab = this.$utils.getPref('settings.tab') || 0;
    this.getSettings();
  },

  watch: {
    tab(t) {
      this.$utils.setPref('settings.tab', t);
    },
  },
});
</script>

<style>
/* Bridge form element between .main and section.settings */
.main > form {
  display: flex;
  flex: 1;
  min-height: 0;
  flex-direction: column;
}

/* Settings page container - flex to fill available space without overflowing */
section.settings {
  display: flex;
  flex-direction: column;
  flex: 1; /* Fill available space in parent */
  min-height: 0; /* Allow flexbox to shrink below content size */
  overflow: hidden;
}

section.settings > header {
  flex-shrink: 0; /* Keep header fixed */
}

section.settings > hr {
  flex-shrink: 0; /* Keep divider fixed */
  margin-bottom: 1rem;
}

/* Settings container with flexbox layout */
.settings-container {
  display: flex;
  flex: 1; /* Take remaining space */
  width: 100%;
  min-height: 0; /* Allow flex shrinking */
  overflow: hidden;
}

/* Vertical tabs layout */
.settings-tabs {
  display: flex;
  width: 100%;
  height: 100%;
  min-height: 0;
}

.settings-tabs .tabs {
  margin-bottom: 0;
  flex-shrink: 0;
  height: 100%;
  overflow-y: auto;
}

/* Sidebar styling */
.settings-tabs .tabs ul {
  flex-direction: column;
  border-bottom: none;
  border-right: 1px solid #dbdbdb;
  min-width: 200px;
  margin: 0;
  height: 100%;
}

.settings-tabs .tabs ul li {
  width: 100%;
  margin-bottom: 0;
}

.settings-tabs .tabs ul li a {
  justify-content: flex-start;
  border-bottom: none;
  border-right: 3px solid transparent;
  padding: 0.75em 1em;
}

.settings-tabs .tabs ul li.is-active a {
  border-right-color: #3273dc;
  border-bottom-color: transparent;
  background-color: #f5f5f5;
}

/* Content area - use position relative instead of flex to avoid stacking tabs */
.settings-tabs .tab-content {
  position: relative;
  flex-grow: 1;
  height: 100%;
  min-height: 0;
}

/* Individual tab items - absolute positioning for overlay behavior */
.settings-tabs .tab-item {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  overflow-y: auto;
  padding: 1.5em;
}

/* Make sure boxes within content don't overflow */
.settings-tabs .tab-content .box {
  max-width: 100%;
}

/* Mobile responsive */
@media screen and (max-width: 768px) {
  section.settings {
    height: 100%; /* Same as desktop - parent handles sizing */
  }

  .settings-tabs .tabs ul {
    min-width: 150px;
    font-size: 0.9em;
  }

  .settings-tabs .tab-item {
    padding: 1em;
  }
}
</style>
