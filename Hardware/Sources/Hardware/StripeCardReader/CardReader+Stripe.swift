import StripeTerminal

extension CardReader {
    init(reader: Reader) {
        let connected = reader.status == .online
        self.status = CardReaderStatus(connected: connected, remembered: false)
        self.name = reader.label ?? "Unknown"
        self.serial = reader.serialNumber
    }
}
