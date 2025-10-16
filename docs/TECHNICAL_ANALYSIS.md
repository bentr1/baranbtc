# Teknik Analiz Algoritmaları

## Genel Bakış

Bu dokümanda, BTC Baran uygulamasında kullanılan üç ana teknik analiz algoritması detaylandırılmıştır. Her algoritma, Binance.com'dan alınan günlük mum verileri üzerinde çalışır ve belirli koşullar sağlandığında uyarı tetikler.

## 1. Pivot Traditional Analizi

### Amaç
Günlük zaman diliminde, her parite için Pivot Traditional Auto R5 değerini hesaplamak ve mum değerlerinin bu seviyeyi %50 üzerinde geçip geçmediğini kontrol etmek.

### Hesaplama Formülü
```
Pivot Point (PP) = (High + Low + Close) / 3

R1 = (2 × PP) - Low
R2 = PP + (High - Low)
R3 = High + 2(PP - Low)
R4 = R3 + (R2 - R1)
R5 = R4 + (R3 - R2)

Uyarı Seviyesi = R5 + (R5 × 0.50)
```

### Tetikleme Koşulu
Bir mumun yüksek (high) değeri, `R5 + (R5 * 0.50)` formülünden elde edilen fiyatı geçerse uyarı tetiklenir.

### Kod Örneği
```typescript
interface PivotAnalysis {
  pair: string;
  date: Date;
  pivot: number;
  r1: number;
  r2: number;
  r3: number;
  r4: number;
  r5: number;
  alertLevel: number;
  isTriggered: boolean;
  highPrice: number;
}

function calculatePivotTraditional(high: number, low: number, close: number): PivotAnalysis {
  const pivot = (high + low + close) / 3;
  const r1 = (2 * pivot) - low;
  const r2 = pivot + (high - low);
  const r3 = high + 2 * (pivot - low);
  const r4 = r3 + (r2 - r1);
  const r5 = r4 + (r3 - r2);
  
  const alertLevel = r5 + (r5 * 0.50);
  
  return {
    pivot,
    r1,
    r2,
    r3,
    r4,
    r5,
    alertLevel,
    isTriggered: false,
    highPrice: 0
  };
}

function checkPivotAlert(analysis: PivotAnalysis, currentHigh: number): boolean {
  return currentHigh >= analysis.alertLevel;
}
```

## 2. S1/R1 Temas Analizi

### Amaç
Son 270 gün içinde mum değerlerinin (hem minimum hem de maksimum) Pivot'un S1 (Destek 1) veya R1 (Direnç 1) seviyesine temas edip etmediğini kontrol etmek.

### Temas Tanımı
Bir mum, aşağıdaki koşullardan herhangi birini sağladığında S1 veya R1'e temas etmiş sayılır:
- `Low <= S1 <= High` (S1 teması)
- `Low <= R1 <= High` (R1 teması)

### Sayaç Mantığı
- **S1 Teması:** Son temas tarihinden itibaren geçen gün sayısı
- **R1 Teması:** Son temas tarihinden itibaren geçen gün sayısı
- Her temas sonrası sayaç sıfırlanır
- 270 gün temas olmazsa uyarı tetiklenir

### Kod Örneği
```typescript
interface S1R1Analysis {
  pair: string;
  date: Date;
  s1: number;
  r1: number;
  s1TouchCount: number;
  r1TouchCount: number;
  lastS1Touch: Date | null;
  lastR1Touch: Date | null;
  s1Alert: boolean;
  r1Alert: boolean;
}

function checkS1R1Touch(
  analysis: S1R1Analysis, 
  currentHigh: number, 
  currentLow: number,
  currentDate: Date
): S1R1Analysis {
  const s1Touched = currentLow <= analysis.s1 && analysis.s1 <= currentHigh;
  const r1Touched = currentLow <= analysis.r1 && analysis.r1 <= currentHigh;
  
  if (s1Touched) {
    analysis.lastS1Touch = currentDate;
    analysis.s1TouchCount = 0;
  } else {
    analysis.s1TouchCount++;
  }
  
  if (r1Touched) {
    analysis.lastR1Touch = currentDate;
    analysis.r1TouchCount = 0;
  } else {
    analysis.r1TouchCount++;
  }
  
  // 270 gün kontrolü
  analysis.s1Alert = analysis.s1TouchCount >= 270;
  analysis.r1Alert = analysis.r1TouchCount >= 270;
  
  return analysis;
}
```

## 3. Hareketli Ortalama (MA) Temas Analizi

### Amaç
25 MA ve 100 MA değerlerinin, farklı zaman dilimlerinde mum değerlerine temas edip etmediğini kontrol etmek.

### Zaman Dilimleri
- **Günlük (1D):** Her gün bir mum
- **3 Günlük (3D):** 3 günde bir mum
- **Haftalık (1W):** Her hafta bir mum

### 25 MA Analizi
- **Hedef:** 50 ardışık mum 25 MA'ya temas etmediğinde uyarı
- **Sayaç:** Temas olmayan ardışık mum sayısı
- **Sıfırlama:** Her temas sonrası

### 100 MA Analizi
- **Hedef:** 200 ardışık mum 100 MA'ya temas etmediğinde uyarı
- **Sayaç:** Temas olmayan ardışık mum sayısı
- **Sıfırlama:** Her temas sonrası

### MA Hesaplama
```typescript
function calculateMA(prices: number[], period: number): number {
  if (prices.length < period) return 0;
  
  const sum = prices.slice(-period).reduce((acc, price) => acc + price, 0);
  return sum / period;
}
```

### Temas Kontrolü
```typescript
interface MAAnalysis {
  pair: string;
  timeframe: '1D' | '3D' | '1W';
  ma25: number;
  ma100: number;
  ma25TouchCount: number;
  ma100TouchCount: number;
  ma25Alert: boolean;
  ma100Alert: boolean;
}

function checkMATouch(
  analysis: MAAnalysis,
  currentHigh: number,
  currentLow: number
): MAAnalysis {
  // 25 MA temas kontrolü
  const ma25Touched = currentLow <= analysis.ma25 && analysis.ma25 <= currentHigh;
  if (ma25Touched) {
    analysis.ma25TouchCount = 0;
  } else {
    analysis.ma25TouchCount++;
  }
  
  // 100 MA temas kontrolü
  const ma100Touched = currentLow <= analysis.ma100 && analysis.ma100 <= currentHigh;
  if (ma100Touched) {
    analysis.ma100TouchCount = 0;
  } else {
    analysis.ma100TouchCount++;
  }
  
  // Uyarı kontrolü
  analysis.ma25Alert = analysis.ma25TouchCount >= 50;
  analysis.ma100Alert = analysis.ma100TouchCount >= 200;
  
  return analysis;
}
```

## Uyarı Tetikleme Sistemi

### Uyarı Tipleri
1. **PIVOT_R5_BREAK** - R5 seviyesi %50 üzeri
2. **S1_NO_TOUCH_270** - 270 gün S1 teması yok
3. **R1_NO_TOUCH_270** - 270 gün R1 teması yok
4. **MA25_NO_TOUCH_50** - 50 mum 25 MA teması yok
5. **MA100_NO_TOUCH_200** - 200 mum 100 MA teması yok

### Uyarı Veri Yapısı
```typescript
interface Alert {
  id: string;
  pair: string;
  alertType: string;
  message: string;
  severity: 'LOW' | 'MEDIUM' | 'HIGH';
  triggeredAt: Date;
  data: any;
  isRead: boolean;
}
```

### Uyarı Mesajları
```typescript
const ALERT_MESSAGES = {
  PIVOT_R5_BREAK: (pair: string, price: number) => 
    `${pair} fiyatı R5 seviyesinin %50 üzerine çıktı: ${price}`,
  
  S1_NO_TOUCH_270: (pair: string) => 
    `${pair} 270 gündür S1 seviyesine temas etmedi`,
  
  R1_NO_TOUCH_270: (pair: string) => 
    `${pair} 270 gündür R1 seviyesine temas etmedi`,
  
  MA25_NO_TOUCH_50: (pair: string, timeframe: string) => 
    `${pair} ${timeframe} zaman diliminde 50 mum 25 MA'ya temas etmedi`,
  
  MA100_NO_TOUCH_200: (pair: string, timeframe: string) => 
    `${pair} ${timeframe} zaman diliminde 200 mum 100 MA'ya temas etmedi`
};
```

## Performans Optimizasyonu

### Veri Önbellekleme
- MA hesaplamaları için son 200 günlük veri cache'lenir
- Pivot hesaplamaları günlük olarak cache'lenir
- S1/R1 temas sayıcıları Redis'te saklanır

### Batch İşleme
- Tüm pariteler için analizler paralel olarak çalıştırılır
- Veritabanı yazma işlemleri batch halinde yapılır
- Uyarı gönderimi kuyruk sistemi ile yönetilir

### Monitoring
- Analiz süreleri ölçülür
- Hata oranları takip edilir
- Performans metrikleri loglanır
