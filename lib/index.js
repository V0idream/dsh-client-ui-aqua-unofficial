import z from "@deepseek-ai/schemastery";
import { settingsNamespace } from "@deepseek-ai/dsh-settings";
//#region lib/types/index.js
/**
* Aqua theme-layer plugin, node half.
*
* rc.7 upgrade: the Plugins settings section now dispatches its
* `settings.plugin.item` card slot by the settings namespace each card edits
* (keyed slot). So this node half serves the `aqua` settings namespace, and
* the browser half registers its master-switch card under the same key — the
* section pairs the two without learning what the namespace means.
*
* The visual layer state itself stays a browser-local preference (localStorage),
* owned by the client half; the settings document below is the durable
* master-switch record that also validates stored values. The browser half
* ships via exports["./client"], discovered through the package.json
* dsh.client declaration.
*/
/** Settings namespace the aqua card claims in the configurable-plugins tab. */
const AQUA_SETTINGS_NAMESPACE = "aqua";
/** Host settings schema for the `aqua` namespace. */
const AquaSettingsSchema = z.object({ enabled: z.boolean().default(true) });
/** Host plugin body: serve the `aqua` settings namespace for the card slot. */
function apply(ctx) {
	ctx.inject(["settings"], (settingsCtx) => {
		settingsCtx.settings.register(settingsNamespace(AQUA_SETTINGS_NAMESPACE), AquaSettingsSchema);
	});
}
//#endregion
export { AQUA_SETTINGS_NAMESPACE, AquaSettingsSchema, apply };
