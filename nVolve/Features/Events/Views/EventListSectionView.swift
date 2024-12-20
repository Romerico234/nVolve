//
//  EventListSectionView.swift
//  nVolve
//
//  Created by Romerico David on 11/25/24.
//

import SwiftUI

struct EventListSection: View {
    @State var viewModel: ContentViewModel
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel

    var sortedEvents: [EventModel] {
        var events = viewModel.filteredEvents
        events.sort { (event1: EventModel, event2: EventModel) -> Bool in
            let isFav1 = favoritesViewModel.isFavorited(event: event1)
            let isFav2 = favoritesViewModel.isFavorited(event: event2)
            if isFav1 != isFav2 {
                return isFav1 && !isFav2
            } else {
                let date1 = event1.time
                let date2 = event2.time
                return date1 < date2
            }
        }
        return events
    }

    var body: some View {
        if sortedEvents.isEmpty {
            // Display a message when no events are found
            Text("Sorry, no events meet these conditions")
                .font(.title)
                .foregroundColor(.gray)
                .padding(.top, 110)
                .padding(.bottom, 60)
        }
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 10) {
                ForEach(sortedEvents.indices, id: \.self) { index in
                    EventCard(
                        event: sortedEvents[index]
                    )
                }
            }
            .padding(.horizontal)
        }
        .background(Color.white)
    }
}
