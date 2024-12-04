
public class Sender {
    0 => int active;

    fun void setActive(int v) {
        v => active;
    }
}

public class Receiver {
    fun void activate() {}
}

public class Signal {
    string name;
    Sender _senders[0];
    Receiver _receivers[0];

    0 => int used;

    fun Signal(string _name) {
        _name => name;
    }

    fun void addSender(Sender @ s) {
        _senders << s;
    }
    fun void addReceiver(Receiver @ r) {
        _receivers << r;
    }

    fun int check() {
        if (used) return 0;
        for (Sender @ s : _senders) {
            if (!s.active) return 0;
        }
        <<< "Signal", name, "activated!" >>>;
        for (Receiver @ r : _receivers) {
            r.activate();
        }
        1 => used;
        return 1;
    }

    fun void reset() {
        0 => used;
    }
}
