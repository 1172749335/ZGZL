package.loaded["app.common.sound"] = nil
package.loaded["app.common.BaseLayer"] = nil
package.loaded["app.common.DialogLayer"] = nil
package.loaded["app.common.LoadingLayer"] = nil
package.loaded["app.common.ToastLayer"] = nil

require("app.common.sound")
require("app.common.BaseLayer")
require("app.common.DialogLayer")
require("app.common.LoadingLayer")
require("app.common.ToastLayer")

if loadingLayer then
	loadingLayer:release()
end
loadingLayer = LoadingLayer.new()
loadingLayer:retain()

if toastLayer then
	toastLayer:release()
end
toastLayer = ToastLayer.new()
toastLayer:retain()