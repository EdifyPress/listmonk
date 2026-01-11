<template>
  <div class="items">
    <b-tabs :animated="false" v-model="tab">
      <!-- Branding Tab -->
      <b-tab-item v-if="$isVisible('settings.appearance.branding')" label="Branding" label-position="on-border">
        <div class="block">
          <p class="help">Customize the branding of your ListMonk instance. Upload images via the Media library and paste URLs here.</p>
        </div>

        <b-field v-if="$isVisible('settings.appearance.logo')" label="Logo URL" label-position="on-border">
          <b-input v-model="data['appearance.whitelabel'].logo_url" placeholder="https://your-cdn.com/logo.png" />
          <p class="help">URL to your logo image. Recommended size: 200x50px. Upload via Media library first.</p>
        </b-field>

        <b-field v-if="$isVisible('settings.appearance.favicon')" label="Favicon URL" label-position="on-border">
          <b-input v-model="data['appearance.whitelabel'].favicon_url" placeholder="https://your-cdn.com/favicon.ico" />
          <p class="help">URL to your favicon. Recommended: 32x32px ICO or PNG file.</p>
        </b-field>

        <b-field v-if="$isVisible('settings.appearance.site_name')" label="Site Name" label-position="on-border">
          <b-input v-model="data['appearance.whitelabel'].site_name" placeholder="My Newsletter" />
          <p class="help">Custom name to display in the browser tab and UI. Defaults to "listmonk".</p>
        </b-field>

        <!-- Preview Section -->
        <div v-if="hasAnyBranding" class="box" style="margin-top: 2rem;">
          <h4 class="title is-5">Preview</h4>
          <div class="preview-area">
            <img v-if="data['appearance.whitelabel'].logo_url" :src="data['appearance.whitelabel'].logo_url" alt="Logo Preview" style="max-width: 200px; max-height: 50px;" />
            <p v-if="data['appearance.whitelabel'].site_name"><strong>Site Name:</strong> {{ data['appearance.whitelabel'].site_name }}</p>
            <div v-if="data['appearance.whitelabel'].favicon_url" style="display: flex; align-items: center; gap: 0.5rem;">
              <img :src="data['appearance.whitelabel'].favicon_url" alt="Favicon Preview" style="width: 16px; height: 16px;" />
              <span>Favicon Preview</span>
            </div>
          </div>
        </div>
      </b-tab-item><!-- branding -->

      <!-- Visibility Configuration Tab -->
      <b-tab-item v-if="$isVisible('settings.appearance.visibility')" label="Visibility" label-position="on-border">
        <div class="block">
          <p class="help">
            Control which menu items and settings tabs are visible to users. This is useful for white-labeling
            and simplifying the UI for specific use cases. Missing keys default to visible.
          </p>
          <p class="help" style="margin-top: 0.5rem;">
            <strong>Note:</strong> This tab itself can be hidden! Be careful not to lock yourself out.
            Superadmins (role ID 1) can always see everything.
          </p>
        </div>

        <b-field label="Visibility Configuration (JSON)" label-position="on-border">
          <code-editor
            lang="javascript"
            v-model="visibilityConfigJson"
            name="visibility-config"
            key="editor-visibility-config"
          />

        </b-field>

        <!-- Example Configuration -->
        <details class="box" style="margin-top: 1rem;">
          <summary style="cursor: pointer; font-weight: bold;">Show Example Configuration</summary>
          <div style="margin-top: 1rem; margin-bottom: 1rem;">
            <p class="help">
              <strong>Custom Labels:</strong> Rename menu items and settings tabs by adding a "label" property.
              For example, rename "Campaigns" to "Newsletters".
            </p>
          </div>
          <pre style="margin-top: 0.5rem; background: #f5f5f5; padding: 1rem; border-radius: 4px; overflow-x: auto;"><code>{
  "menu": {
    "subscribers": { "visible": true },
    "subscribers.import": { "visible": true },
    "campaigns": { "visible": true, "label": "Newsletters" },
    "campaigns.analytics": { "visible": false },
    "settings": { "visible": true, "require_role": 1 }
  },
  "settings": {
    "appearance.branding": { "visible": true },
    "appearance.logo": { "visible": true },
    "appearance.favicon": { "visible": true },
    "appearance.site_name": { "visible": true },
    "appearance.visibility": { "visible": false },
    "smtp": { "visible": true, "require_role": 1 },
    "postal": { "visible": true, "require_role": 1 }
  }
}</code></pre>
          <p class="help" style="margin-top: 1rem;">
            <strong>Tip:</strong> Use the browser's Developer Tools to inspect menu items and find their path names.
            Navigation items use "menu.*" paths and settings tabs use "settings.*" paths.
          </p>
        </details>

        <!-- More Examples -->
        <details class="box" style="margin-top: 1rem;">
          <summary style="cursor: pointer; font-weight: bold;">Show More Label Examples</summary>
          <div style="margin-top: 1rem; margin-bottom: 1rem;">
            <p class="help">
              Example: Customize navigation labels for different terminology.
            </p>
          </div>
          <pre style="margin-top: 0.5rem; background: #f5f5f5; padding: 1rem; border-radius: 4px; overflow-x: auto;"><code>{
  "menu": {
    "dashboard": { "label": "Home" },
    "subscribers": { "label": "Members" },
    "campaigns": { "label": "Emails" },
    "templates": { "label": "Designs" },
    "media": { "label": "Files" }
  },
  "settings": {
    "general": { "label": "Basics" },
    "appearance": { "label": "Look & Feel" },
    "api": { "label": "Developers" }
  }
}</code></pre>
          <div style="margin-top: 1rem; margin-bottom: 1rem;">
            <p class="help">
              <strong>Note:</strong> Empty or missing "label" values will use the default translations.
            </p>
          </div>
          <pre style="margin-top: 0.5rem; background: #f5f5f5; padding: 1rem; border-radius: 4px; overflow-x: auto;"><code>{
  "menu": {
    "campaigns": { "visible": true, "label": "" },
    "subscribers": { "visible": true }
    // ↑ campaign will use default "Campaigns" label
    // ↑ subscriber will also use default "Subscribers" label
  }
}</code></pre>
        </details>
      </b-tab-item><!-- visibility -->

      <!-- Custom CSS/JS Tabs -->
      <b-tab-item v-if="$isVisible('settings.appearance.admin')" :label="$t('settings.appearance.adminName')" label-position="on-border">
        <div class="block">
          {{ $t('settings.appearance.adminHelp') }}
        </div>

        <b-field :label="$t('settings.appearance.customCSS')" label-position="on-border">
          <code-editor lang="css" v-model="data['appearance.admin.custom_css']" name="body" key="editor-admin-css" />
        </b-field>

        <b-field :label="$t('settings.appearance.customJS')" label-position="on-border">
          <code-editor lang="javascript" v-model="data['appearance.admin.custom_js']" name="body"
            key="editor-admin-js" />
        </b-field>
      </b-tab-item><!-- admin -->

      <b-tab-item v-if="$isVisible('settings.appearance.public')" :label="$t('settings.appearance.publicName')" label-position="on-border">
        <div class="block">
          {{ $t('settings.appearance.publicHelp') }}
        </div>

        <b-field :label="$t('settings.appearance.customCSS')" label-position="on-border">
          <code-editor lang="css" v-model="data['appearance.public.custom_css']" name="body" key="editor-public-css" />
        </b-field>

        <b-field :label="$t('settings.appearance.customJS')" label-position="on-border">
          <code-editor lang="javascript" v-model="data['appearance.public.custom_js']" name="body"
            key="editor-public-js" />
        </b-field>
      </b-tab-item><!-- public -->
    </b-tabs>
  </div>
</template>

<script>
import Vue from 'vue';
import { mapState } from 'vuex';
import CodeEditor from '../../components/CodeEditor.vue';
import { visibilityMixin } from '../../utils/visibility';

export default Vue.extend({
  components: {
    'code-editor': CodeEditor,
  },

  mixins: [visibilityMixin],

  props: {
    form: {
      type: Object, default: () => { },
    },
  },

  data() {
    return {
      data: this.form,
      tab: 0,
      // Add a reactive counter to force computed property re-evaluation
      visibilityUpdateCounter: 0,
    };
  },

  computed: {
    ...mapState(['settings']),

    // Computed property for visibility config JSON editing
    visibilityConfigJson: {
      get() {
        // Include the counter in the dependency chain to force re-evaluation
        // eslint-disable-next-line no-unused-vars
        const counter = this.visibilityUpdateCounter;

        // Access the data property directly to ensure Vue tracks it reactively
        if (!this.data || !this.data['appearance.whitelabel']) {
          return JSON.stringify({
            menu: {},
            settings: {},
          }, null, 2);
        }

        const config = this.data['appearance.whitelabel'].visibility_config;
        if (!config) {
          return JSON.stringify({
            menu: {},
            settings: {},
          }, null, 2);
        }

        // Pretty print JSON
        return typeof config === 'string' ? config : JSON.stringify(config, null, 2);
      },
      set(value) {
        // Ensure appearance.whitelabel exists
        if (!this.data['appearance.whitelabel']) {
          this.$set(this.data, 'appearance.whitelabel', {
            logo_url: '',
            favicon_url: '',
            site_name: '',
            visibility_config: {},
          });
        }

        try {
          // Validate JSON before saving
          const parsed = JSON.parse(value);
          // Directly replace the entire visibility_config object to trigger reactivity
          this.data['appearance.whitelabel'] = {
            ...this.data['appearance.whitelabel'],
            visibility_config: parsed,
          };
          // Increment counter to force getter re-evaluation
          this.visibilityUpdateCounter += 1;
        } catch (e) {
          // Don't update on invalid JSON - just let user keep typing
          // eslint-disable-next-line no-console
          console.warn('Invalid JSON in visibility config:', e);
        }
      },
    },

    // Check if any branding fields are set for preview
    hasAnyBranding() {
      const wl = this.data['appearance.whitelabel'];
      return wl && (wl.logo_url || wl.favicon_url || wl.site_name);
    },
  },

  mounted() {
    this.tab = this.$utils.getPref('settings.apperanceTab') || 0;
  },

  watch: {
    tab(t) {
      this.$utils.setPref('settings.apperanceTab', t);
    },
  },
});

</script>

<style scoped>
/* Nested tabs within Appearance tab */
.items {
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* Make nested .b-tabs fill available space */
.items .b-tabs {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-height: 0;
}

/* Nested tabs navigation - horizontal layout and prevent growth */
.items .b-tabs nav.tabs {
  flex: 0 0 auto;
  height: auto;
}

.items .b-tabs nav.tabs ul {
  flex: 0 0 auto;
  flex-direction: row !important; /* Horizontal tabs - override Buefy's vertical default */
}

/* Remove blue right border from nested tab links */
.items .b-tabs nav.tabs a {
  border-right: none !important;
}

/* Nested tab content container */
.items .b-tabs .tab-content {
  flex: 1;
  min-height: 0;
}

/* Form field layout improvements for Branding tab */
.field.has-addons {
  flex-direction: column;
  align-items: flex-start;
}

.field .control {
  width: 100%;
  max-width: 800px;
}

.field input[type="text"],
.field input[type="url"],
.field textarea {
  width: 100%;
}

.field p.help {
  width: 100%;
  max-width: 800px;
  margin-top: 0.5rem;
}
</style>

<style>
/* Non-scoped styles for Buefy components that need to override framework defaults */
/* Vue's scoped styles add data attributes that don't work on dynamically rendered Buefy components */

/* Force nested tabs in Appearance section to display horizontally */
.items .b-tabs nav.tabs ul {
  flex-direction: row !important;
}

/* Fix nested tabs layout - prevent nav from taking up all vertical space */
.items .b-tabs nav.tabs {
  height: auto !important;
  flex: 0 0 auto !important;
}

/* Ensure tab content takes remaining space and is visible */
.items .b-tabs .tab-content {
  flex: 1 !important;
  display: block !important;
}

/* Remove blue right border from nested tab links */
.items .b-tabs nav.tabs a {
  border-right: none !important;
}

/* Make form fields full width and stack help text below */
.items .b-tabs .tab-content .field {
  display: flex;
  flex-direction: column;
  width: 100%;
  max-width: none;
}

.items .b-tabs .tab-content .field .control {
  width: 100%;
  max-width: none;
}

.items .b-tabs .tab-content .field .control input {
  width: 100% !important;
  max-width: none !important;
}

.items .b-tabs .tab-content .field p.help {
  order: 2;
  margin-top: 0.5rem;
  width: 100%;
}
</style>
