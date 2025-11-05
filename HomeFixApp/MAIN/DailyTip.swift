import Foundation

struct DailyTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    
    static let allTips: [DailyTip] = [
        DailyTip(title: "Unclog a Drain Naturally", description: "Pour half a cup of baking soda, followed by half a cup of vinegar, down the drain. Wait 15 minutes, then flush with hot water."),
        DailyTip(title: "Silence a Squeaky Door", description: "Apply a small amount of petroleum jelly or cooking oil to the hinge pins to stop annoying squeaks without a mess."),
        DailyTip(title: "Remove Water Stains from Wood", description: "Gently rub a mixture of non-gel toothpaste and baking soda on the stain with a soft cloth. Wipe clean and polish as usual."),
        DailyTip(title: "Clean Grout with Ease", description: "Create a paste of baking soda and water. Apply it to the grout, spray with vinegar, and scrub with a small brush after it stops foaming."),
        DailyTip(title: "Fix a Wobbly Chair", description: "Inject wood glue into loose joints using a syringe. Clamp the joint tightly for 24 hours for a solid, lasting repair."),
        DailyTip(title: "Natural Air Freshener", description: "Simmer a pot of water with citrus peels and cinnamon sticks on the stove for a fresh, chemical-free home scent."),
        DailyTip(title: "Test Your Smoke Detectors", description: "Press and hold the test button on your smoke detectors monthly. Remember to change the batteries at least once a year."),
        DailyTip(title: "Improve Refrigerator Efficiency", description: "Clean the condenser coils on the back or bottom of your fridge twice a year. This helps it run more efficiently and saves energy."),
        DailyTip(title: "Patch Small Nail Holes", description: "A white bar of soap or non-gel toothpaste can be used to fill small nail holes in a pinch. Just rub it over the hole and wipe away the excess."),
        DailyTip(title: "Keep Paint Fresh", description: "Place plastic wrap under the lid before sealing a paint can. This creates an airtight seal and prevents the paint from drying out." )
    ]
}
