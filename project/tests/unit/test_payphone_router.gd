extends GutTest
## Patch's heat rule (quest collect-call, mechanic payphone-job-router): a call rings only at
## heat 0, a hot pick-up is refused and keeps the phone quiet until the heat is 0, a cool
## pick-up of a ringing phone connects.

const PHONE: String = "Harbor Road"

var _router: PayphoneRouter


func before_each() -> void:
	_router = PayphoneRouter.new()


func test_the_refusal_line_is_patchs() -> void:
	assert_eq(_router.refuse_line["speaker"], "patch")
	assert_eq(_router.refuse_line["key"], "PAYPHONE__PATCH__REFUSE_HOT")
	assert_ne(_router.refuse_line["text"], "")


func test_a_call_rings_only_at_heat_zero() -> void:
	_router.queue_call(PHONE)
	_router.step(2)
	assert_false(_router.ringing(PHONE), "hot: the phone stays quiet")
	_router.step(0)
	assert_true(_router.ringing(PHONE))
	_router.step(1)
	assert_false(_router.ringing(PHONE), "heat came back: it stops ringing")


func test_patch_refuses_a_hot_caller_and_the_phone_goes_quiet_until_cool() -> void:
	_router.queue_call(PHONE)
	_router.step(0)
	assert_true(_router.ringing(PHONE))
	assert_eq(_router.pick_up(PHONE, 3), PayphoneRouter.Pickup.REFUSED_HOT)
	assert_eq(_router.refusals, 1)
	assert_false(_router.connected(PHONE), "Patch drops the call")
	for heat: int in [3, 2, 1]:
		_router.step(heat)
		assert_false(_router.ringing(PHONE), "quiet at heat %d" % heat)
		assert_eq(_router.pick_up(PHONE, heat), PayphoneRouter.Pickup.REFUSED_HOT)
	_router.step(0)
	assert_true(_router.ringing(PHONE), "heat 0: it rings again")
	assert_eq(_router.pick_up(PHONE, 0), PayphoneRouter.Pickup.CONNECTED)
	assert_true(_router.connected(PHONE))


func test_a_quiet_phone_is_a_dial_tone_and_a_hot_one_still_refuses() -> void:
	assert_eq(_router.pick_up(PHONE, 0), PayphoneRouter.Pickup.DIAL_TONE)
	assert_eq(_router.pick_up(PHONE, 2), PayphoneRouter.Pickup.REFUSED_HOT)
	assert_false(_router.ringing(PHONE))
