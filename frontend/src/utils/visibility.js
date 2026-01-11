/**
 * White-labeling visibility utility
 * Checks if a UI element should be visible based on visibility_config and user role
 */

/**
 * Check if an item is visible based on visibility config AND user role
 * @param {Object} visibilityConfig - The visibility_config from settings
 * @param {string} path - Dot-separated path (e.g., "menu.subscribers.import")
 * @param {string|number} userRole - Current user's role from JWT (name or id)
 * @returns {boolean} - True if visible, false if hidden
 */
export function isVisible(visibilityConfig, path, userRole) {
  // If no config or path, default to visible
  if (!visibilityConfig || !path) return true;

  // Split path into section and item keys
  // e.g., "menu.subscribers.import" -> section="menu", itemKey="subscribers.import"
  const [section, ...keys] = path.split('.');
  const sectionConfig = visibilityConfig[section] || {};
  const itemKey = keys.join('.');

  // Get the item config
  const item = sectionConfig[itemKey];

  // If no config for this item, default to visible
  if (!item) return true;

  // Check visibility flag first
  if (item.visible === false) {
    return false;
  }

  // Check role requirement if specified
  if (item.require_role) {
    // Support both role name (string) and role ID (number)
    // Role ID 1 is always superadmin (bypass checks)
    if (userRole === 1 || userRole === '1') {
      return true;
    }

    // Check if user has the required role
    // Support comparing both string and number values
    const requiredRole = item.require_role;
    const hasRole = (
      userRole === requiredRole
      || String(userRole) === String(requiredRole)
    );

    if (!hasRole) {
      return false;
    }
  }

  // Default to visible
  return true;
}

/**
 * Check if a settings section separator should be shown
 * Only show separator if both sections are visible
 */
export function shouldShowSeparator(visibilityConfig, section1, section2, userRole) {
  return (
    isVisible(visibilityConfig, section1, userRole)
    && isVisible(visibilityConfig, section2, userRole)
  );
}

/**
 * Get custom label for a menu item or settings tab
 * Falls back to defaultLabel if no custom label is specified
 * @param {Object} visibilityConfig - The visibility_config from settings
 * @param {string} path - Dot-separated path (e.g., "menu.subscribers")
 * @param {string} defaultLabel - The default label from i18n
 * @returns {string} - Custom label if valid, otherwise defaultLabel
 */
export function getLabel(visibilityConfig, path, defaultLabel) {
  if (!visibilityConfig || !path || !defaultLabel) {
    return defaultLabel;
  }

  // Split path into section and item keys
  const [section, ...keys] = path.split('.');
  const sectionConfig = visibilityConfig[section] || {};
  const itemKey = keys.join('.');

  // Get the item config
  const item = sectionConfig[itemKey];

  if (!item || typeof item !== 'object') {
    return defaultLabel;
  }

  // Return custom label if it's a non-empty string
  if (typeof item.label === 'string' && item.label.trim() !== '') {
    return item.label.trim();
  }

  // Fallback to default
  return defaultLabel;
}

/**
 * Vue mixin to add $isVisible and $getLabel methods to all components
 * Usage: v-if="$isVisible('menu.subscribers')"
 * Usage: :label="$getLabel('menu.campaigns', $t('globals.terms.campaigns'))"
 */
export const visibilityMixin = {
  methods: {
    $isVisible(path) {
      // Get visibility config from settings in Vuex store
      // appearance.whitelabel is a nested object, not a flat key
      const whitelabel = this.$store.state.settings?.['appearance.whitelabel'];
      const visibilityConfig = whitelabel?.visibility_config;

      // Get user role from profile in Vuex store
      const userRole = this.$store.state.profile?.userRole?.id;

      return isVisible(visibilityConfig, path, userRole);
    },

    $getLabel(path, defaultLabel) {
      // Get visibility config from settings in Vuex store
      // appearance.whitelabel is a nested object, not a flat key
      const whitelabel = this.$store.state.settings?.['appearance.whitelabel'];
      const visibilityConfig = whitelabel?.visibility_config;

      return getLabel(visibilityConfig, path, defaultLabel);
    },
  },
};
