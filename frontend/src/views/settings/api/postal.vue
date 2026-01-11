<template>
  <div :class="{ disabled: disabled }">
    <b-field :label="$t('settings.postal.apiURL')" label-position="on-border"
      :message="$t('settings.postal.apiURLHelp')">
      <b-input v-model="data.postal.api_url" name="api_url"
        placeholder="https://postal.example.com" :maxlength="500" :disabled="disabled" />
    </b-field>

    <b-field :label="$t('settings.postal.apiKey')" label-position="on-border"
      :message="$t('settings.postal.apiKeyHelp')">
      <b-input v-model="data.postal.api_key" name="api_key" type="password"
        :placeholder="$t('settings.postal.apiKeyHelp')" :maxlength="200" :disabled="disabled" />
    </b-field>

    <hr />

    <div class="notification is-info is-light">
      <p>
        <strong>{{ $t('settings.postal.webhookInfo') }}</strong>
      </p>
      <p class="mt-2">
        {{ $t('settings.postal.webhookEndpoint') }}:
        <code>{{ rootURL }}/api/webhooks/postal</code>
      </p>
      <p class="mt-2">
        {{ $t('settings.postal.webhookHelp') }}
      </p>
    </div>
  </div>
</template>

<script>
import Vue from 'vue';
import { mapState } from 'vuex';

export default Vue.extend({
  props: {
    form: { type: Object, default: () => ({}) },
    disabled: { type: Boolean, default: false },
  },

  data() {
    return {
      data: this.form,
    };
  },

  computed: {
    ...mapState(['serverConfig']),

    rootURL() {
      return this.form['app.root_url'] || window.location.origin;
    },
  },
});
</script>

<style scoped>
.disabled {
  opacity: 0.5;
  pointer-events: none;
}
</style>
