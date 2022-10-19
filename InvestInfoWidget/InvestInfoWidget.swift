//
//  InvestInfoWidget.swift
//  InvestInfoWidget
//
//  Created by Albert on 22.09.2022.
//

import WidgetKit
import SwiftUI
import InvestInfo

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Утренний фон")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: date)!
        let timeline = Timeline(entries: [Entry(date: date, title: "Утренний фон")],
                                policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
}

struct InvestInfoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: "news1")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(12)
                .frame(height: 200)
            HStack {
                Text(entry.title)
                    .padding(.leading, 30)
                    .font(.title)
                Spacer()
            }
            Text("Нефть. Сегодня ожидаем Brent в диапазоне $90-93/барр. Нефть довольно устойчива, поддержкой выступает отсутствие прогресса по иранской ядерной сделке, а значит риск профицита предложения при замедляющемся спросе ниже.\n\n💵 Валютный рынок. Потенциал для укрепления рубля сохраняется, курс доллара сегодня, возможно, перейдет в диапазон 59-60 руб.\n\n📈 Рынок акций. Индекс МосБиржи сегодня находится в диапазоне 2400-2500 пунктов в ожидании триггеров, которые помогут определиться с дальнейшей динамикой.")
                .padding(12)
            Text(Date(), style: .time)
            Spacer()
        }
    }
}

@main
struct InvestInfoWidget: Widget {
    let kind: String = "InvestInfoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            InvestInfoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

struct InvestInfoWidget_Previews: PreviewProvider {
    static var previews: some View {
        InvestInfoWidgetEntryView(entry: SimpleEntry(date: Date(), title: "Утренний фон"))
            .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
        InvestInfoWidgetEntryView(entry: SimpleEntry(date: Date(), title: "Утренний фон"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        InvestInfoWidgetEntryView(entry: SimpleEntry(date: Date(), title: "Утренний фон"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        InvestInfoWidgetEntryView(entry: SimpleEntry(date: Date(), title: "Утренний фон"))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
