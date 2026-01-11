<template>
  <div :class="{ disabled: disabled }">
    <b-field :label="$t('settings.sendgrid.apiKey')" label-position="on-border"
      :message="$t('settings.sendgrid.apiKeyHelp')">
      <b-input v-model="data.sendgrid.api_key" name="api_key" type="password"
        :placeholder="$t('settings.sendgrid.apiKeyHelp')" :maxlength="200" :disabled="disabled" />
    </b-field>

    <hr />

    <div class="notification is-info is-light">
      <p>
        <strong>{{ $t('settings.sendgrid.info') }}</strong>
      </p>
      <p class="mt-2">
        {{ $t('settings.sendgrid.infoHelp') }}
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
