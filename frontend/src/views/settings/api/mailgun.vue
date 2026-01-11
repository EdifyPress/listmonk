<template>
  <div :class="{ disabled: disabled }">
    <b-field :label="$t('settings.mailgun.apiKey')" label-position="on-border"
      :message="$t('settings.mailgun.apiKeyHelp')">
      <b-input v-model="data.mailgun.api_key" name="api_key" type="password"
        :placeholder="$t('settings.mailgun.apiKeyHelp')" :maxlength="200" :disabled="disabled" />
    </b-field>

    <b-field :label="$t('settings.mailgun.domain')" label-position="on-border"
      :message="$t('settings.mailgun.domainHelp')">
      <b-input v-model="data.mailgun.domain" name="domain"
        placeholder="mg.example.com" :maxlength="200" :disabled="disabled" />
    </b-field>

    <b-field :label="$t('settings.mailgun.region')" label-position="on-border"
      :message="$t('settings.mailgun.regionHelp')">
      <b-select v-model="data.mailgun.region" name="region" :disabled="disabled">
        <option value="us">{{ $t('settings.mailgun.regionUS') }}</option>
        <option value="eu">{{ $t('settings.mailgun.regionEU') }}</option>
      </b-select>
    </b-field>

    <hr />

    <div class="notification is-info is-light">
      <p>
        <strong>{{ $t('settings.mailgun.info') }}</strong>
      </p>
      <p class="mt-2">
        {{ $t('settings.mailgun.infoHelp') }}
      </p>
    </div>
  </div>
</template>

<script>
import Vue from 'vue';

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
});
</script>

<style scoped>
.disabled {
  opacity: 0.5;
  pointer-events: none;
}
</style>
