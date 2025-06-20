import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DanhNgonScreen extends StatefulWidget {
  const DanhNgonScreen({super.key});

  @override
  _DanhNgonScreenState createState() => _DanhNgonScreenState();
}

class _DanhNgonScreenState extends State<DanhNgonScreen> {
  String selectedContent = 'Danh ngôn tình yêu và hạnh phúc';

  final List<Map<String, dynamic>> drawerItems = [
    {'id': 1, 'title': 'Danh ngôn tình yêu và hạnh phúc'},
    {'id': 2, 'title': 'Danh ngôn tình yêu buồn'},
    {'id': 3, 'title': 'Danh ngôn tình yêu thất bại'},
    {'id': 4, 'title': 'Danh ngôn tình yêu và nổi nhớ'},
    {'id': 5, 'title': 'Danh ngôn tình yêu chia sẻ nhiều'},
  ];

  IconData iconCustom = Icons.format_quote;
  Color iconColor = Colors.redAccent;
  Color colorCustom = Colors.lightBlueAccent;
  Color colorText = Colors.white;

  final List<String> data = [
    "Vị trà yêu thích của anh là gì? Đó là em.",
    "Chocolate đắng dâu tươi nhưng ngọt ở cuống họng, như tình yêu em dành cho anh.",
    "Anh có thể làm mọi thứ cho em, ngoại trừ việc yêu em lần nữa.",
    "Trong 6 tỉ người, anh nhỏ bé, nhưng 5,999,999,999 người còn lại không thể thay thế em.",
    "Bên em thôi, đừng bên ai. Yêu em thôi, đừng thêm ai.",
    "Như lon coca mùa hè, hạt cacao mùa đông. Em đến bên anh thật nhanh và đúng lúc.",
    "Người được tình yêu làm cho tươi sáng hơn mới yêu thực sự.",
    "Một cách đơn giản để hạnh phúc là tôn trọng những gì mình đang có.",
    "Người giàu thêm tiền, người nghèo thêm tiền, nhưng chỉ có anh là thêm hạnh phúc.",
    "Cách ai đó gọi tên bạn cũng khiến bạn mỉm cười khi yêu.",
    "Tôi yêu người ấy bằng thứ tình cảm chân thành nhất, chỉ cần người đó không buông tay thì dù trái đất này có ngừng quay tôi cũng không bao giờ buông tay người ấy.",
    "Nếu khoảng cách giữa chúng ta là một nghìn bước, em chỉ cần bước 1 bước, 999 bước còn lại anh sẽ chạy đến cùng em",
    "Yêu một người là nghĩ về người đó cuối cùng trước khi đi ngủ và nhớ về người đó đầu tiên khi tỉnh dậyDuyên do trời định, phận do trời tạo nhưng hạnh phúc là do chính bản thân mình tạo ra. Hãy nhớ và trân trọng điều đó nhé!",
    "Tình yêu không phải là những lời thề non hẹn biển, chỉ đơn giản là cùng nhau bình yên qua ngày.",
    "Em sợ quá anh ơi, chắc em phải đi khám bác sĩ thôi. Chẳng hiểu sao cả tuần qua trong đầu em chỉ luôn hiện lên hình bóng anh và tim em đập thình thịch khi nghe thấy giọng nói của anh. Chắc em yêu anh quá mất rồi",
    "Em à, anh đã bị cảm nắng và bệnh đã rất nặng rồi. Liều thuốc duy nhất có thể cứu anh bây giờ là được nhìn thấy ánh mắt, nụ cười hoặc chỉ cần một tình yêu nhỏ em dành cho anh.",
    "Tình yêu đâu phải vì tiền. Tình yêu đâu phải ngẫu nhiên mà thành. Tình yêu đâu phải tranh giành. Tình yêu là phải chân thành, thủy chung!",
    "Tình yêu biến những điều vô nghĩa của cuộc đời thành những gì có ý nghĩa, làm cho những bất hạnh trở thành hạnh phúc.",
    "Cảm giác hạnh phúc và bình yên nhất chính là được ôm trọn người mình yêu vào buổi tối và nhìn thấy họ đầu tiên vào buổi sáng.",
    "Duyên do trời se, phận do trời tạo. Nhưng hạnh phúc là do chính bản thân mình tạo nên. Vì thế, hãy trân trọng người đang đi cùng bạn và cùng nhau cố gắng vì điều đó.",
    "Trong cuộc đời, điều hạnh phúc nhất không phải là được rất nhiều người yêu bạn. Mà hạnh phúc nhất chính là được một người yêu bạn đến khắc cốt ghi tâm. Vì bạn mà làm tất cả.",
    "Hạnh phúc trong tình yêu không phải điều gì to lớn, đôi khi hạnh phúc đơn giản chỉ là cùng nhau làm những điều nhỏ nhặt mỗi ngày.",
    "Hạnh phúc của anh chính là vì em mà cố gắng, vì em mà thay đổi. Em chính là động lực tuyệt vời nhất trong cuộc đời anh.",
    "Muốn hạnh phúc trong tình yêu hãy cho đi nhiều hơn, hãy tha thứ, hãy thông cảm, và hãy yêu thương nhiều hơn.",
    "Với anh, có rất nhiều cô gái xung quanh anh để yêu thương. Nhưng để anh yêu thương chân thành nhất, sâu sắc nhất, thì anh chỉ có thể dành cho em – người con gái anh yêu.",
    "Món quà duy nhất anh có thể dành tặng em, chính là anh. Món quà ấy bây giờ và mãi mãi vẫn luôn bên cạnh em, yêu thương em. Dù đi đâu, cũng luôn hướng về em.",
    "Anh yêu em, vì vậy anh sẽ luôn bên cạnh em, quan tâm em vì em mà làm tất cả. chỉ cần em hạnh phúc. Anh chỉ cần, dù khó khăn đến đâu em vẫn luôn bên cạnh anh, cùng anh đi qua những ngày giông tố. Để phía cuối con đường chính là hạnh phúc của hai ta.",
    "Anh có biết không, những dòng sông dù có chảy quanh co đến đâu cũng sẽ chảy về thiên đường. Và những người yêu nhau dù đi cả vòng trái đất vẫn quay về bên cạnh nhau.",
    "Tình đầu và tình cuối khác nhau ở điểm gì? Tình đầu là tình cảm bạn nghĩ đây là cuối cùng. Tình cuối cho bạn thấy đây mới là mối tình đầu tiên",
  ];
  final List<String> dataTinhYeuBuon = [
    "Tình yêu giống như thiên đường, nhưng nỗi đau nó gây ra thì như địa ngục vậy.",
    "Rồi một ngày anh sẽ nhận ra, không phải ánh nắng nào cũng đẹp, cơn mưa nào cũng nhẹ, ngọn gió nào cũng mát. Và không phải người con gái nào cũng yêu anh như em đã yêu anh.",
    "Một bàn tay dù to thế nào cũng không thể giữ một bàn tay đã không muốn nắm. Một vòng tay dù có rộng bao nhiêu cũng chẳng thể ôm trọn một người đã muốn rời đi.",
    "Sợ lắm cái cảm giác tưởng chừng như ôm trọn yêu thương… rồi bỗng nhiên biến mất như chưa từng tồn tại.",
    "Đường lâu ngày không đi sẽ mọc đầy cỏ dại. Người lâu ngày không gặp bỗng trở thành người dưng.",
    "Cứ sống cho người khác vì sợ người ta bị tổn thương. Để rồi khi ngoảnh mặt người bị đau nhất lại là chính mình.",
    "Đừng vì quá cô đơn mà nắm nhầm 1 bàn tay. Đừng vì quá lạnh mà vội ôm 1 bờ vai",
    "Sâu thẳm như mối tình đầu và điên cuồng bằng tất cả niềm nuối tiếc.",
    "Đừng lãng phí thời gian với những người không có thời gian dành cho bạn.",
    "Có lẽ điều khó khăn nhất trong cuộc sống này chính là nhìn người mà bạn yêu, yêu một ai đó khác.",
    "Khi ai đó làm ta tổn thương, ta học được cách để trở nên mạnh mẽ. Khi ai đó rời bỏ ta, ta học được cách trở nên tự lập hơn.",
    "Trong tình yêu, tôi không thôi chờ đợi, không phải chờ đợi một người nào đó sẽ yêu tôi, mà là chờ đợi cho đến khi tôi có thể quên đi và ngừng yêu ai đó.",
    "Trên đời này không có người vô tâm. Chỉ là tâm của họ không hướng về bạn mà thôi.",
    "Khi bạn yêu thật lòng một ai đó bạn sẽ hiểu sự im lặng của người ta có sức tàn phá như thế nào trong tim bạn!",
    "Bi kịch trong tình yêu mà người con gái nào cũng phải sợ, đó chính là “yêu nhầm người”",
    "Hãy chọn một kết thúc buồn thay vì một nỗi buồn không bao giờ kết thúc.",
    "Tôi cũng có tình yêu của riêng mình, chỉ có điều người tôi yêu chưa từng yêu tôi.",
    "Tha thứ thì dễ dàng nhưng tin tưởng một lần nữa thì không dễ dàng như vậy.",
    "Cái lạnh nhất không phải là cơn gió khi trời sang đông mà là sự vô tâm của một người mà bạn xem là tất cả.",
  ];
  final List<String> dataTinhYeuThatBai = [
    "Phụ nữ chỉ nhớ người đàn ông làm cho họ cười. Đàn ông chỉ yêu người phụ nữ làm cho họ khóc.",
    "Nếu một ngày nào đó tôi biến mất. Liệu có ai nhớ và đi tìm tôi không.",
    "Cuộc sống sẽ thật buồn khi có những người mình yêu nhưng cả đời không thể ở bên cạnh họ được. Và có những người yêu mình muốn bên cạnh mình nhưng không thể ừ được.",
    "Sau khi chia tay thứ mà mình cảm thấy mất mát nhiều nhất có lẽ là niềm tin.",
    "Nỗi buồn lớn nhất là không yêu nhưng vẫn cố tỏ ra hạnh phúc, nỗi đau lớn nhất là đau nhưng vẫn phải cố gắng mỉn cười.",
    "Tình yêu bắt đầu khi cả 2 nhìn vào mặt tích cực của nhau. Và kết thúc khi cả 2 người chỉ nhìn thấy điểm tiêu cực của nhau.",
    "Yêu đơn phương là một thứ tình cảm thật đẹp, cảm ơn cuộc đời đã cho anh được gặp em và yêu em dù chỉ là trong thầm lặng.",
    "Yêu đơn phương là chìm đắm trong thứ cảm giác khi nhìn ngắm người ấy mà ánh mắt của họ không bao giờ hướng về phía ta.",
    "Có những nỗi nhớ không được đặt tên, có những yêu thương không được gửi trao nhưng vẫn lâng lâng hạnh phúc vì được yêu đúng với cảm xúc trái tim, đó là tình yêu đơn phương.",
    "Đừng buồn vì không có được người ấy, mà phải cố gắng sống sao để người ấy hối hận vì không có được bạn.",
    "Bạn nên hiểu rằng có những người dù bạn cố gắng quan tâm đến họ như thế nào đi chăng nữa, họ cũng sẽ chẳng bao giờ để ý đến bạn nữa đâu.",
    "Anh đang rất nhớ em, thực sự rất nhớ nhưng chẳng có cách gì để đến gần em hơn và ôm em thật chặt.",
    "Đây là lần cuối em quan tâm anh, khóc vì anh và từ giờ em sẽ ngừng khóc, ngừng yêu thương!",
    "Đừng buồn vì quá khứ bạn không có được người ấy …. Mà hãy sống làm sao để người ấy buồn vì tương lai họ sẽ không có bạn !",
    "Em mệt lắm ! Em đang cảm thấy bị bỏ rơi, nói mà chẳng có ai nghe, em buồn mà không có ai thấu, em cô đơn mà không có một người ở bên",
    "Hạnh phúc … thì chẳng được bao lâu Mà nỗi đau …. thì in sâu chẳng thể xóa ! Anh nhớ em nhiều lắm",
    "Im lặng là cách tốt nhất để biết ai đang cần ta và ai đang nhớ đến ta.",
    "Bình yên nhất với một cô gái là được người mình yêu thương ôm trọn vào lòng và quên đi tất cả …! Em nhớ anh thật nhiều",
    "Đủ nắng hoa sẽ nở và đủ yêu thương thì hạnh phúc sẽ đong đầy",
    "Hai con người, hai thành phố, hai kiểu thời tiết nhưng trái tim cùng một nhịp đập, cùng đợi chờ một điều gì đó, Đây có phải là … Yêu Xa !",
    "Có một thứ tình cảm âm thầm nhưng cháy bỏng, cồn cào. Vậy mà chỉ dám đứng nhìn từ xa … yêu đơn phương là thế đó !",
  ];
  final List<String> dataTinhYeuVaNoiNho = [
    "Mỗi khi em nhớ anh, một vì sao trên trời lại rơi xuống. Thế nên, nếu anh ngước nhìn bầu trời mà chỉ thấy một màn đêm tối mịt không một ánh sao, lỗi tại anh cả đó. Anh đã khiến em nhớ anh biết bao nhiêu!",
    "Nhớ em là sở thích của tôi, chăm sóc em là công việc của tôi, làm cho em hạnh phúc là trách nhiệm của tôi, và yêu em là cuộc đời tôi.",
    "Khi em cảm thấy cô đơn, cứ nhìn vào khoảng trống giữa những ngón tay em, và hãy nhớ rằng ở giữa những khoảng trống đó, là ngón tay anh đang chặt ngón tay em, mãi mãi.",
    "Sau này, đã có rất nhiều người con gái hỏi tôi rằng, tôi có nhớ họ không?",
    "Tôi trả lời: Tôi sẽ nhớ về họ. Nhưng người mà tôi nhớ nhất trong đời, lại",
    "là người không bao giờ hỏi tôi điều đó”…",
    "✮ Nếu anh chưa từng gặp em, anh sẽ không thích em \n"
        "✮ Nếu anh chưa từng thích em, anh sẽ không yêu em \n"
        "✮ Nếu anh chưa từng yêu em, anh sẽ không nhớ em \n"
        "✮ Nhưng anh đã yêu, đang yêu và sẽ mãi mãi luôn yêu em",
    "Em nhớ anh khi điều gì đó thật sự tốt đẹp xảy ra, bởi anh là người em muốn chia sẻ. Em nhớ anh khi điều gì đó làm em sầu não, bởi anh là người rất hiểu em. Em nhớ anh khi em cười và khóc, bởi em biết anh có thể giúp em nhân lên nụ cười vào lau đi nước mắt. Lúc nào em cũng nhớ anh, nhưng em nhớ anh nhất khi em thao thức trong đêm, nghĩ về tất cả những khoảng thời gian tuyệt vời mà chúng ta ở bên nhau.",
    "Đôi khi họ nhắc tới tên anh, và rồi ai đó hỏi em liệu em biết anh không. Em quay đi, nhớ về tất cả khoảng thời gian chúng ta ở bên nhau, chia sẻ tiếng cười, nước mắt, những câu đùa và vô số nữa, và rồi, anh ra đi không lời giải thích. Em nhìn về nơi họ đang chờ đợi câu trả lời của em và em nói khẽ: ‘Đã từng có lúc… tôi nghĩ mình biết.’",
    "Anh không bao giờ vượt ra khỏi nhịp đập trái tim em, nhưng em vẫn nhớ anh.",
  ];
  final List<String> chucngungon = [
    "Em có biết em chính là lý do mà hàng đêm anh không ngủ được và anh chỉ ngủ được khi nói với em rằng: “Chúc em ngủ ngon” ngủ ngon nhé cô bé!.	",
    "Sông có thể cạn núi có thể mòn nhưng với anh việc chúc em ngủ ngon sẽ không bao giờ thay đổi. Chúc em ngủ thật ngon em yêu nhé!	",
    "Hãy đem tất cả những niềm vui của ngày hôm nay vào giấc ngủ và ngủ thật ngon để mơ thấy thật nhiều giấc mơ hạnh phúc em nhé…	",
    "Nhớ em quá! Ngủ ngoan nhé, không được đạp chăn ra đâu, lạnh lắm đấy! Anh ngủ đây.	",
    "Anh nhắn tin cho em... chỉ muốn chúc em ngủ ngon thôi... Hãy ngủ thật ngon vào em nhé! Yêu em nhiều!	",
    "Sắp hết một ngày rồi em ạ. Không biết anh có phải là người cuối cùng nhắn tin cho em không? Anh nhắn tin để chúc em ngủ ngon trước khi sang ngày mới dù anh biết em còn thức rất khuya.	",
    "Chúc em ngủ ngon nhé cô bé đáng yêu! Một ngày của anh không thể kết thúc nếu không có điều gì đó để làm. Anh sẽ không thể ngủ mà không nói rằng :'chúc em ngủ ngon'	"
        "Một ngày nữa lại trôi qua và ngày mới lại bắt đầu, chúc em ngủ ngon và có giấc mơ đẹp.	",
    "Chúc em yêu mơ những giấc mơ đẹp và biến nó thành thực nhé!	",
    "Chúc ngủ ngon người yêu của anh, đêm nay chúc em có một giấc mơ ngập tràn hạnh phúc và tiếng cười.	",
    "Khi anh cô đơn trong đêm và anh nhìn lên những ngôi sao vĩ đại của vũ trụ, điều duy nhất mà anh muốn thấy chính là em. Good night!",
  ];

  List<String> data1 = [];
  void _onSelectItem(int id) {
    setState(() {
      // Kiểm tra id và thay đổi dữ liệu theo lựa chọn
      switch (id) {
        case 1:
          selectedContent = 'Danh ngôn tình yêu và hạnh phúc';
          data1 = data;
          iconCustom = Icons.favorite;
          iconColor = Colors.redAccent;
          colorCustom = Colors.lightBlueAccent;
          colorText = Colors.white;
          break;
        case 2:
          selectedContent = 'Danh ngôn tình yêu buồn';
          data1 = dataTinhYeuBuon;
          iconCustom = Icons.heart_broken;
          iconColor = Colors.blueGrey;
          colorCustom = Colors.grey;
          colorText = Colors.black;
          break;
        case 3:
          selectedContent = 'Danh ngôn tình yêu thất bại';
          data1 = dataTinhYeuThatBai;
          iconCustom = Icons.sentiment_dissatisfied;
          iconColor = Colors.black;
          colorCustom = Colors.purple;
          colorText = Colors.white;
          break;
        case 4:
          selectedContent = 'Danh ngôn tình yêu và nổi nhớ';
          data1 = dataTinhYeuVaNoiNho;
          iconCustom = Icons.cloud;
          iconColor = Colors.white;
          colorCustom = Colors.lightBlue;
          colorText = Colors.black;
          break;
        case 10:
          selectedContent = 'Chúc ngủ ngon';
          data1 = chucngungon;
          iconCustom = Icons.bed;
          iconColor = Colors.black;
          colorCustom = Colors.yellow;
          colorText = Colors.black;
          break;
        default:
          data1 = data; // Mặc định
          iconCustom = Icons.share;
          iconColor = Colors.green;
          colorCustom = Colors.orange;
          colorText = Colors.white;
      }
    });

    Navigator.of(context).pop(); // Đóng Drawer sau khi chọn
  }

  @override
  void initState() {
    super.initState();
    // Tự động load dữ liệu "Danh ngôn tình yêu và hạnh phúc"
    data1 = data;
    iconCustom = Icons.favorite;
    iconColor = Colors.redAccent;
    colorCustom = Colors.lightBlueAccent;
    colorText =
        Colors.white; // Màu tương ứng với "Danh ngôn tình yêu và hạnh phúc"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Ngôn Hay'),
        backgroundColor: Colors.pink,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 100.0,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.pinkAccent.shade100),
                child: const Text(
                  'Danh ngôn',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              title: const Text('Danh ngôn tình yêu hạnh phúc'),
              onTap: () {
                _onSelectItem(1);
              },
            ),
            ListTile(
              title: const Text('Danh ngôn tình yêu buồn'),
              onTap: () {
                _onSelectItem(2);
              },
            ),
            ListTile(
              title: const Text('Danh ngôn tình yêu thất bại'),
              onTap: () {
                _onSelectItem(3);
              },
            ),
            ListTile(
              title: const Text('Danh ngôn tình yêu và nổi nhớ'),
              onTap: () {
                _onSelectItem(4);
              },
            ),
            ListTile(
              title: const Text('Danh ngôn tình yêu chia sẻ nhiều'),
              onTap: () {
                _onSelectItem(5);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Danh ngôn tình yêu hài hước & bá đạo'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Danh ngôn tình yêu tiếng Anh'),
              onTap: () {},
            ),
            const Divider(),
            const ListTile(
              title: Text(
                'Ký tự đẹp',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(title: const Text('Ký tự tình yêu đẹp'), onTap: () {}),
            const Divider(),
            const ListTile(
              title: Text(
                'Lời chúc',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Chúc ngủ ngon'),
              onTap: () {
                _onSelectItem(10);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedContent,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: data1.length,
                itemBuilder: (context, index) {
                  return _buildQuoteCard(data1[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(String quote) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: quote)); // Sao chép vào clipboard
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(quote)));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: colorCustom, // Set background color of the card
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                iconCustom,
                color: iconColor,
                size: 32,
              ), // White icon for contrast
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  quote,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorText,
                  ), // White text color for contrast
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
