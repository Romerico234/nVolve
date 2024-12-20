//
//  EventInfo.swift
//  nVolve
//
//  Created by Rasheed Nolley on 11/11/24.
//

import SwiftUI
import MapKit

struct EventInfo: View {
    @Binding var showEvent: Bool
    let event: EventModel
    @State private var favorited = false
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @State private var showBottomSheet = false

    var body: some View {
        ZStack {
            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header with title and close button
                    HStack {
                        Text(event.eventName)
                            .font(.system(size: 28, weight: .bold))
                            .lineLimit(2)
                            .padding(.leading)

                        Spacer()

                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.red)
                            .onTapGesture {
                                showEvent = false
                            }
                            .padding(.trailing)
                    }
                    .padding(.top, 10)

                    // Event image
                    if let url = URL(string: event.eventImage) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        } placeholder: {
                            ProgressView()
                                .frame(maxHeight: 200)
                        }
                    }

                    // Event details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time: \(parseEventTime(event.time))")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Location: \(event.eventLocation)")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(event.eventDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }

                    // Perks section
                    if !event.perks.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Perks")
                                .font(.headline)

                            ForEach(event.perks, id: \.self) { perk in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(perk)
                                        .font(.body)
                                }
                            }
                        }
                        .padding(.top)
                    }

                    Spacer()
                }
                .padding()
                .padding(.bottom, 80)
            }

            // Fixed bottom action buttons
            VStack {
                Spacer()
                HStack(spacing: 16) {
                    Spacer()

                    // Get Directions Button
                    Button(action: {
                        showBottomSheet = true
                    }) {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Get Directions")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 275)
                        .frame(height: 65)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 10)

                    // Favorite Button
                    Button(action: {
                        favorited.toggle()
                            if favorited {
                                favoritesViewModel.addFavorite(event: event)
                            } else {
                                favoritesViewModel.removeFavorite(event: event)
                            }
                            showEvent = false
                    }) {
                        Image(systemName: favorited ? "heart.fill" : "heart")
                            .font(.system(size: 36))
                            .foregroundColor(favorited ? .red : .gray)
                    }
                    .padding(.bottom, 10)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .background(Color(UIColor.systemBackground).opacity(0.95))
            }
        }
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            if let event = favoritesViewModel.findEventByID(id: event.id) {
                favorited = favoritesViewModel.isFavorited(event: event)
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            MapSelectionSheet(
                showBottomSheet: $showBottomSheet,
                eventLat: event.lat,
                eventLng: event.long,
                title: event.eventName
            )
            .presentationDetents([.medium, .large])
        }
    }
}

private func parseEventTime(_ timeString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a"
    dateFormatter.amSymbol = "am"
    dateFormatter.pmSymbol = "pm"

    if let date = isoFormatter.date(from: timeString) {
        return dateFormatter.string(from: date)
    }

    return "Invalid Time"
}
