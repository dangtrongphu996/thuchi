import 'package:thuchi/screens/docsach/entity/chapter.dart';
import 'package:thuchi/screens/docsach/entity/phan.dart';

class Book {
  final String title;
  final String coverImage; // Đường dẫn ảnh bìa sách
  final String pdfPath;
  final List<Phan> phans;

  Book({
    required this.title,
    required this.coverImage,
    required this.phans,
    required this.pdfPath,
  });
}

List<Book> books = [
  Book(
    title: "Biến mọi thứ thành tiền",
    coverImage: 'assets/images/Bien-Moi-Thu-Thanh-Tien-600x940.jpg',
    pdfPath: "assets/pdf/bien_moi_thu_thanh_tien.pdf",
    phans: [
      Phan(
        title: "Phần I:Khát vọng biến mọi thứ thành tiền",
        chapters: [
          Chapter(
            title: "Chương I: Bạn đã thực sự hiểu về tiền ",
            startPage: 6,
            endPage: 41,
          ),
          Chapter(
            title:
                "Chương II: Tại sao bạn luôn gặp khó khăn trong việc kiếm tiền",
            startPage: 43,
            endPage: 58,
          ),
        ],
      ),
      Phan(
        title: "Phần II:Biến mọi thứ thành tiền",
        chapters: [
          Chapter(
            title: "Chương I: Bắt đầu với bất cứ thứ gì",
            startPage: 62,
            endPage: 68,
          ),
          Chapter(
            title: "Chương II: Các cấp độ của tiền",
            startPage: 70,
            endPage: 96,
          ),
          Chapter(
            title: "Chương III: Phát triển nguồn sinh ra tiền",
            startPage: 98,
            endPage: 132,
          ),
        ],
      ),
    ],
  ),
  Book(
    title: "Tư duy ngược",
    coverImage: 'assets/images/tu-duy-nguoc.png',
    pdfPath: "assets/pdf/Tu-duy-nguoc.pdf",
    phans: [
      Phan(
        title: "PHẦN 01 BẠN ĐÃ SỐNG CUỘC ĐỜI THẾ NÀO?",
        chapters: [
          Chapter(
            title: "01 May mắn có phải bổng dưng mà có",
            startPage: 6,
            endPage: 13,
          ),
          Chapter(
            title: "02 Hãy vứt bỏ sự kỳ vọng và khát khao làm hài lòng kẻ khác",
            startPage: 15,
            endPage: 18,
          ),
          Chapter(
            title: "03 Tâm bạn ở đâu, thành công của bạn ở đó",
            startPage: 19,
            endPage: 22,
          ),
          Chapter(
            title: "04 Sống ngược dòng, vạn người mê",
            startPage: 23,
            endPage: 28,
          ),
          Chapter(
            title: "05 Chiến thắng nỗi sợ bên trong bạn",
            startPage: 29,
            endPage: 32,
          ),
          Chapter(title: "06 Sống khác đám đông", startPage: 34, endPage: 40),
          Chapter(
            title:
                "07 Cuộc đời có vô vàn cách sống, hãy sống cuộc đời của mình",
            startPage: 42,
            endPage: 44,
          ),
          Chapter(
            title: "08 Vì sao bạn nghèo, làm thế nào để giàu có?",
            startPage: 46,
            endPage: 48,
          ),
        ],
      ),
      Phan(
        title: "PHẦN 02 SỐNG CUỘC ĐỜI BẠN MUỐN",
        chapters: [
          Chapter(
            title: "01 Công thức để thành công, bạn đã biết chưa?",
            startPage: 51,
            endPage: 56,
          ),
          Chapter(
            title: "02 Dũng cảm theo đuổi công việc mơ ước",
            startPage: 58,
            endPage: 62,
          ),
          Chapter(
            title: "03 Bạn đang dốc hết sức hay chỉ đơn giản là cố hết sức?",
            startPage: 64,
            endPage: 69,
          ),
          Chapter(
            title: "04 Dám khác biệt dám đột phá",
            startPage: 71,
            endPage: 74,
          ),
          Chapter(
            title: "05 Trình bày ý tưởng trước đám đông",
            startPage: 76,
            endPage: 80,
          ),
          Chapter(
            title: "06 Nghĩ khác đi, kết quả tốt hơn",
            startPage: 84,
            endPage: 87,
          ),
          Chapter(
            title: "07 Không ngừng tử tế, không ngừng học hỏi",
            startPage: 89,
            endPage: 93,
          ),
          Chapter(
            title: "08 Trở thành chuyên gia trong lĩnh vực của bạn",
            startPage: 95,
            endPage: 98,
          ),
          Chapter(
            title: "09 Trở thành một nhà lãnh đạo bản thân kiệt xuất",
            startPage: 100,
            endPage: 102,
          ),
          Chapter(
            title: "10 Nghệ thuật tập trung",
            startPage: 104,
            endPage: 108,
          ),
        ],
      ),
      Phan(
        title: "PHẦN 03 LỰA CHỌN THẬT SỰ RẤT DỄ DÀNG",
        chapters: [
          Chapter(
            title: "01 Sức mạnh của thói quen",
            startPage: 111,
            endPage: 115,
          ),
          Chapter(
            title: "02 Hãy tạo thói quen mới",
            startPage: 117,
            endPage: 121,
          ),
          Chapter(
            title: "03 Đừng ngại đổi thay, đời sẽ thay đổi",
            startPage: 123,
            endPage: 125,
          ),
          Chapter(
            title: "04 Cho đi sẽ nhận lại nhiều hơn",
            startPage: 127,
            endPage: 131,
          ),
          Chapter(
            title:
                "05 Làm sao để suy nghĩ tích cực giữa thế giới ảo đầy thị phi?",
            startPage: 133,
            endPage: 135,
          ),
          Chapter(
            title: "06 Khi bạn quyết định đổi mình",
            startPage: 137,
            endPage: 139,
          ),
          Chapter(
            title: "07 Tận hưởng từng phút giây",
            startPage: 141,
            endPage: 144,
          ),
          Chapter(title: "08 Sống dũng cảm", startPage: 146, endPage: 148),
          Chapter(
            title: "09 Hạnh phúc thực sự là gì",
            startPage: 150,
            endPage: 151,
          ),
          Chapter(
            title: "10 Sáng tạo hay là chết",
            startPage: 153,
            endPage: 157,
          ),
        ],
      ),
    ],
  ),
  Book(
    title: "Tư duy mở",
    coverImage: 'assets/images/tu-duy-mo.png',
    pdfPath: "assets/pdf/Tu-duy-mo.pdf",
    phans: [
      Phan(
        title: "PHẦN I BẠN LÀ NGƯỜI THẾ NÀO?",
        chapters: [
          Chapter(
            title:
                "01 Thế nào là tư duy đóng, tư duy mở? Bạn đang tư duy như thế nào?",
            startPage: 8,
            endPage: 14,
          ),
          Chapter(
            title: "02 Đâu là con người bạn muốn trở thành",
            startPage: 16,
            endPage: 16,
          ),
          Chapter(
            title: "03 Thay đổi tư duy, hành động cảm xúc mà bạn muốn ",
            startPage: 18,
            endPage: 19,
          ),
          Chapter(
            title: "04 Bạn thông minh hơn bạn nghĩ nhiều",
            startPage: 21,
            endPage: 26,
          ),
          Chapter(
            title: "05 Đánh thức sự tự tin trong bạn",
            startPage: 28,
            endPage: 29,
          ),
          Chapter(
            title: "06 Dũng cảm đối mặt thử thách",
            startPage: 31,
            endPage: 31,
          ),
          Chapter(
            title: "07 Thất bại là chuyện bình thường",
            startPage: 33,
            endPage: 34,
          ),
          Chapter(title: "08 Ngưng kiểm soát", startPage: 35, endPage: 35),
          Chapter(title: "09 Học cách sáng tạo", startPage: 37, endPage: 39),
          Chapter(title: "10 Tư duy đã chiều", startPage: 41, endPage: 42),
        ],
      ),
      Phan(
        title: "Phần II BẠN - THAY ĐỔI HAY LÀ CHẾT",
        chapters: [
          Chapter(
            title: "01 Bước qua vùng an toàn - luôn muốn thử cái mới",
            startPage: 44,
            endPage: 46,
          ),
          Chapter(
            title: "02 Bình tĩnh giúp bạn có được mọi thứ",
            startPage: 48,
            endPage: 49,
          ),
          Chapter(
            title: "03 Các quy luật tập trung then chốt",
            startPage: 51,
            endPage: 52,
          ),
          Chapter(
            title:
                "04 Quản lí thời gian hiệu quả - Chìa khóa của sự thành công",
            startPage: 54,
            endPage: 57,
          ),
          Chapter(title: "05 Học cách quyết định", startPage: 59, endPage: 60),
          Chapter(
            title: "06 Xây dựng thói quen hiệu quả",
            startPage: 62,
            endPage: 63,
          ),
          Chapter(
            title: "07 Nghĩ ngược lại và làm khác đi",
            startPage: 65,
            endPage: 67,
          ),
          Chapter(
            title: "08 Thử thách giúp bạn phát triển",
            startPage: 70,
            endPage: 72,
          ),
          Chapter(
            title: "09 Kiên trì học hỏi đóng gói thành công",
            startPage: 73,
            endPage: 74,
          ),
          Chapter(
            title: "10 Chính tôi quyết định khả năng của tôi",
            startPage: 76,
            endPage: 79,
          ),
        ],
      ),
      Phan(
        title: "PHẦN III BẠN - PHIÊN BẢN HOÀN HẢO CỦA CHÍNH MÌNH",
        chapters: [
          Chapter(title: "01 Luôn biết lắng nghe", startPage: 85, endPage: 87),
          Chapter(title: "02 Cho đi nhiều hơn", startPage: 88, endPage: 91),
          Chapter(title: "03 Luôn nói 'Yes'", startPage: 92, endPage: 93),
          Chapter(
            title: "04 Học cách nói 'Tôi không biết'",
            startPage: 94,
            endPage: 97,
          ),
          Chapter(
            title: "05 Đạo đức ư, hãy bỏ nó sang một bên",
            startPage: 99,
            endPage: 99,
          ),
          Chapter(
            title: "06 Đơn thuần như một đứa trẻ",
            startPage: 101,
            endPage: 101,
          ),
          Chapter(
            title: "07 Thuyết phục bất kỳ ai",
            startPage: 103,
            endPage: 103,
          ),
          Chapter(
            title: "08 Bỏ lại quá khứ, hãy sống một cuộc sống có giá trị",
            startPage: 105,
            endPage: 105,
          ),
          Chapter(
            title: "09 Đạt được sự chủ động trong cuộc sống",
            startPage: 107,
            endPage: 110,
          ),
          Chapter(
            title: "10 Thấu hiểu chính mình và mọi người xung quanh",
            startPage: 112,
            endPage: 114,
          ),
        ],
      ),
      Phan(
        title: "PHẦN IV:BẠN - MỌI THỨ TRONG TẦM TAY",
        chapters: [
          Chapter(
            title: "01 Học hỏi từ sai lầm của người khác",
            startPage: 117,
            endPage: 118,
          ),
          Chapter(
            title: "02 Không tức giận khi mình làm sai",
            startPage: 120,
            endPage: 122,
          ),
          Chapter(
            title: "03 Luôn khen ngợi người khác",
            startPage: 125,
            endPage: 126,
          ),
          Chapter(
            title: "04 Khiêm tốn về sự hiểu biết của chính mình",
            startPage: 128,
            endPage: 129,
          ),
          Chapter(
            title: "05 Vui vẻ trước thành quả của người khác",
            startPage: 131,
            endPage: 133,
          ),
          Chapter(
            title: "06 Thưởng thức thế giới xung quanh bạn",
            startPage: 135,
            endPage: 136,
          ),
          Chapter(
            title: "07 Thiết lập mục tiêu cho mọi việc",
            startPage: 138,
            endPage: 138,
          ),
          Chapter(
            title: "08 Cân bằng cơ thể và tâm trí",
            startPage: 141,
            endPage: 143,
          ),
          Chapter(
            title: "09 Sống như ngày mai sẽ chết",
            startPage: 145,
            endPage: 146,
          ),
          Chapter(
            title: "10 Hạnh phúc là một lựa chọn",
            startPage: 148,
            endPage: 149,
          ),
        ],
      ),
    ],
  ),
  Book(
    title: "Khéo ăn nói có được thiên hạ",
    coverImage: "assets/images/kheo-an-noi-se-co-duoc-thien-ha.jpg",
    phans: [
      Phan(
        title: "PHẦN 1: DÁM NÓI CHUYỆN – NẮM VỮNG KỸ NĂNG GIAO TIẾP ",
        chapters: [
          Chapter(
            title: "CHƯƠNG 1: Dũng cảm mở lời, dám nói mới biết cách nói",
            startPage: 8,
            endPage: 23,
          ),
          Chapter(
            title:
                "CHƯƠNG 2: Đọc nhiều – đi nhiều, tích lũy kiến thức giao tiếp",
            startPage: 25,
            endPage: 32,
          ),
          Chapter(
            title: "CHƯƠNG 3: “Bắt bệnh” để làm chủ cuộc giao tiếp",
            startPage: 34,
            endPage: 52,
          ),
          Chapter(
            title: "CHƯƠNG 4: Nắm vững chừng mực trong giao tiếp",
            startPage: 54,
            endPage: 69,
          ),
          Chapter(
            title:
                "CHƯƠNG 5: Khen nhiều chê ít, tránh để lời nói làm hại đến thân",
            startPage: 71,
            endPage: 76,
          ),
          Chapter(
            title: "CHƯƠNG 6: Thêm gia vị hài hước cho giao tiếp",
            startPage: 78,
            endPage: 94,
          ),
        ],
      ),
      Phan(
        title:
            "PHẦN 2: KỸ NĂNG GIAO TIẾP VỚI MỖI HOÀN CẢNH VÀ ĐỐI TƯỢNG KHÁC NHAU",
        chapters: [
          Chapter(
            title:
                "CHƯƠNG 7: Kỹ năng giao tiếp với mỗi hoàn cảnh và đối tượng khác nhau",
            startPage: 96,
            endPage: 112,
          ),
          Chapter(
            title:
                "CHƯƠNG 8: Cách giao tiếp với lãnh đạo để giành cơ hội phát triển nghề nghiệp",
            startPage: 115,
            endPage: 135,
          ),
          Chapter(
            title:
                "CHƯƠNG 9: Chốn công sở nhiều thị phi, biết cách ăn nói rất quan trọng",
            startPage: 137,
            endPage: 153,
          ),
          Chapter(
            title: "CHƯƠNG 10: Khéo ăn nói trong nghệ thuật bán hàng",
            startPage: 155,
            endPage: 181,
          ),
          Chapter(
            title:
                "CHƯƠNG 11: Rèn luyện tài đàm phán, luôn nắm chắc phần thắng",
            startPage: 183,
            endPage: 205,
          ),
          Chapter(
            title: "CHƯƠNG 12: Kỹ năng diễn thuyết sinh động",
            startPage: 207,
            endPage: 222,
          ),
          Chapter(
            title:
                "CHƯƠNG 13: Nắm chắc kỹ năng ngôn ngữ giúp bạn hòa nhập buổi tiệc",
            startPage: 225,
            endPage: 234,
          ),
          Chapter(
            title: "CHƯƠNG 14: Những lời nói ngọt ngào trong tình yêu",
            startPage: 236,
            endPage: 248,
          ),
        ],
      ),
      Phan(
        title: "PHẦN 3: NÓI NĂNG KHÉO LÉO TRONG NHỮNG TÌNH HUỐNG KHÓ XỬ ",
        chapters: [
          Chapter(
            title:
                "CHƯƠNG 15: Từ chối khéo léo để không làm mất lòng người khác",
            startPage: 250,
            endPage: 264,
          ),
          Chapter(
            title: "CHƯƠNG 16: Khéo ăn nói khi nhờ người khác giúp đỡ",
            startPage: 266,
            endPage: 278,
          ),
          Chapter(
            title: "CHƯƠNG 17: Nghệ thuật thuyết phục",
            startPage: 280,
            endPage: 290,
          ),
          Chapter(
            title:
                "CHƯƠNG 18: Con người khó tránh việc mắc lỗi, cần thành khẩn khi xin lỗi",
            startPage: 292,
            endPage: 300,
          ),
          Chapter(
            title: "CHƯƠNG 19: Lời nói thật dễ nghe, khéo léo trong phê bình",
            startPage: 302,
            endPage: 310,
          ),
          Chapter(
            title: "CHƯƠNG 20: Nghệ thuật an ủi làm ấm lòng người khác",
            startPage: 312,
            endPage: 320,
          ),
        ],
      ),
    ],
    pdfPath: "assets/pdf/Kheo-an-noi-se-co-duoc-thien-ha.pdf",
  ),
  Book(
    title: "Nghệ thuật giao tiếp để thành công",
    coverImage: 'assets/images/nghe-thuat-giao-tiep-de-thanh-cong.jpg',
    pdfPath: "assets/pdf/nghethuatgiaotiepdethanhcong.pdf",
    phans: [
      Phan(
        title: "PHẦN 1. SỰ CUỐN HÚT KHÔNG LỜI",
        chapters: [
          Chapter(
            title: "Chương I SỰ CUỐN HÚT KHÔNG LỜI",
            startPage: 7,
            endPage: 20,
          ),
        ],
      ),
      Phan(
        title: "PHẦN 2. THỦ THUẬT BẮT CHUYỆN",
        chapters: [
          Chapter(
            title: "Chương II:THỦ THUẬT BẮT CHUYỆN",
            startPage: 22,
            endPage: 37,
          ),
        ],
      ),
      Phan(
        title: "PHẦN 3. ĐỂ GIAO TIẾP ĐẦY UY LỰC",
        chapters: [
          Chapter(
            title: "Chương III:ĐỂ GIAO TIẾP ĐẦY UY LỰC",
            startPage: 39,
            endPage: 52,
          ),
        ],
      ),
      Phan(
        title: "PHẦN 4. CÁCH ĐỂ TRỞ THÀNH NGƯỜI TRONG CUỘC",
        chapters: [
          Chapter(
            title: "Chương IV:CÁCH ĐỂ TRỞ THÀNH NGƯỜI TRONG CUỘC",
            startPage: 54,
            endPage: 61,
          ),
        ],
      ),
      Phan(
        title: "PHẦN 5. THỦ THUẬT TẠO SỰ TƯƠNG ĐỒNG",
        chapters: [
          Chapter(
            title: "Chương V:THỦ THUẬT TẠO SỰ TƯƠNG ĐỒNG",
            startPage: 63,
            endPage: 69,
          ),
        ],
      ),
      Phan(
        title:
            "PHẦN 6. PHÁT HUY SỨC MẠNH CỦA LỜI KHEN VÀ TRÁNH NỊNH HÓT LỐ BỊCH",
        chapters: [
          Chapter(
            title:
                "Chương VI:PHÁT HUY SỨC MẠNH CỦA LỜI KHEN VÀ TRÁNH NỊNH HÓT LỐ BỊCH",
            startPage: 71,
            endPage: 78,
          ),
        ],
      ),
      Phan(
        title: "PHẦN 7. KẾT NỐI TRỰC TIẾP ĐẾN TRÁI TIM",
        chapters: [
          Chapter(
            title: "Chương VII:KẾT NỐI TRỰC TIẾP ĐẾN TRÁI TIM",
            startPage: 80,
            endPage: 89,
          ),
        ],
      ),
      Phan(
        title: "PHẦN 8. DỰ TIỆC GIỐNG NHƯ MỘT CHÍNH TRỊ GIA",
        chapters: [
          Chapter(
            title: "Chương VIII:DỰ TIỆC GIỐNG NHƯ MỘT CHÍNH TRỊ GIA",
            startPage: 91,
            endPage: 99,
          ),
        ],
      ),
      Phan(
        title: "PHẦN 9. PHÁ BỎ TRỞ NGẠI LỚN NHẤT",
        chapters: [
          Chapter(
            title: "Chương IX:PHÁ BỎ TRỞ NGẠI LỚN NHẤT",
            startPage: 101,
            endPage: 115,
          ),
        ],
      ),
    ],
  ),
  Book(
    title: "Tiền đẻ ra tiền",
    coverImage: 'assets/images/Tien-De-Ra-Tien.jpg',
    pdfPath: "assets/pdf/tienderatien.pdf",
    phans: [
      Phan(
        title: "GIỚI THIỆU",
        chapters: [Chapter(title: "GIỚI THIỆU", startPage: 7, endPage: 15)],
      ),
      Phan(
        title: "PHẦN 01 LÝ THUYẾT TIỀN TỆ",
        chapters: [
          Chapter(
            title: "01 TIỀN LÀ CÔNG CỤ – BẠN PHẢI HỌC CÁCH SỬ DỤNG",
            startPage: 17,
            endPage: 21,
          ),
          Chapter(
            title: "02 DỪNG LO LẮNG, NGƯNG MƠ MỘNG – HÃY BẮT ĐẦU NGHĨ",
            startPage: 23,
            endPage: 27,
          ),
          Chapter(
            title: "03 LẬP NGÂN SÁCH LÀ HỮU ÍCH",
            startPage: 29,
            endPage: 35,
          ),
          Chapter(
            title: "04 ĐỒNG TIỀN NÀY GIÁ TRỊ HƠN ĐỒNG TIỀN KIA",
            startPage: 37,
            endPage: 39,
          ),
          Chapter(
            title: "05 HỌ NHẬN ĐƯỢC GÌ TỪ ĐÓ?",
            startPage: 41,
            endPage: 44,
          ),
          Chapter(title: "06 HÃY CÓ TỔ CHỨC", startPage: 46, endPage: 50),
          Chapter(
            title: "07 VIỆC NẮM BẮT VÀ CẬP NHẬT THÔNG TIN THỰC SỰ ĐÁNG GIÁ",
            startPage: 52,
            endPage: 58,
          ),
          Chapter(title: "08 BIẾT VỀ NHỮNG CHU KỲ", startPage: 60, endPage: 64),
        ],
      ),
      Phan(
        title: "PHẦN 02 KIẾM TIỀN NHIỀU HƠN",
        chapters: [
          Chapter(
            title: "01 TỐI ĐA HÓA LƯƠNG CỦA BẠN",
            startPage: 66,
            endPage: 76,
          ),
          Chapter(title: "02 GIA TĂNG THU NHẬP", startPage: 78, endPage: 84),
          Chapter(title: "03 THU NHẬP TRỌN ĐỜI", startPage: 86, endPage: 99),
          Chapter(title: "04 TRỞ NÊN GIÀU CÓ", startPage: 101, endPage: 105),
        ],
      ),
      Phan(
        title: "PHẦN 03 CHI TIÊU",
        chapters: [
          Chapter(
            title: "01 GIÁ TRỊ THỰC SỰ CỦA TÀI SẢN",
            startPage: 107,
            endPage: 111,
          ),
          Chapter(
            title: "02 BẠN CÓ THẬT SỰ CẦN NÓ KHÔNG?",
            startPage: 113,
            endPage: 118,
          ),
          Chapter(
            title: "03 MÓN ĐỒ NÀY THỰC SỰ ĐÁNH GIÁ BAO NHIÊU?",
            startPage: 120,
            endPage: 125,
          ),
          Chapter(title: "04 KIỂM SOÁT CHI TIÊU", startPage: 127, endPage: 131),
          Chapter(title: "05 CHI TIÊU TRỌN ĐỜI", startPage: 133, endPage: 137),
          Chapter(
            title: "06 CÁCH TỐT NHẤT ĐỂ MUA MỘT CHIẾC XE",
            startPage: 139,
            endPage: 143,
          ),
          Chapter(title: "07 CÁCH THANH TOÁN", startPage: 145, endPage: 152),
        ],
      ),
    ],
  ),
  Book(
    title: "Mặt dầy tâm đen",
    coverImage: 'assets/images/matdaytamden.png',
    pdfPath: "assets/pdf/matdaytamden.pdf",
    phans: [
      Phan(
        title: "Phần 1",
        chapters: [
          Chapter(
            title: "Chương 01 ĐIỂM CỐT YẾU CỦA MẶT DÀY, TÂM ĐEN",
            startPage: 11,
            endPage: 24,
          ),
          Chapter(
            title:
                "Chương 02 Sự chuẩn bị cho Mặt Dày, Tâm Đen\nMười một nguyên tắc về việc gạt bỏ những gì đã học",
            startPage: 25,
            endPage: 57,
          ),
          Chapter(
            title: "Chương 03 Dharma: Cây hoàn thành ước nguyện",
            startPage: 58,
            endPage: 71,
          ),
          Chapter(
            title: "Chương 04 Dharma và định mệnh",
            startPage: 72,
            endPage: 84,
          ),
          Chapter(
            title: "Chương 05 Chiến thắng nhờ lối tư duy tiêu cực",
            startPage: 85,
            endPage: 102,
          ),
          Chapter(
            title: "Chương 06 SỨC MẠNH KỲ DIỆU CỦA SỰ CHỊU ĐỰNG",
            startPage: 103,
            endPage: 119,
          ),
          Chapter(
            title: "Chương 07 Bí mật về tiền",
            startPage: 120,
            endPage: 138,
          ),
          Chapter(
            title: "Chương 08 Dối trá mà không lừa lọc",
            startPage: 139,
            endPage: 150,
          ),
          Chapter(
            title: "Chương 09 16 thuộc tính cao quý của lao động",
            startPage: 151,
            endPage: 163,
          ),
          Chapter(
            title: "Chương 10 Lợi ích của việc đóng vai kẻ khờ",
            startPage: 164,
            endPage: 169,
          ),
        ],
      ),
    ],
  ),
  Book(
    title: "Quẵng gánh lo đi và vui sống",
    coverImage: "assets/images/nhasachmienphi-quang-ganh-lo-di-va-vui-song.jpg",
    phans: [
      Phan(
        title: "PHẦN I. NHỮNG PHƯƠNG PHÁP CĂN BẢN ĐỂ DIỆT LO",
        chapters: [
          Chapter(
            title: "Chương 1. Đắc nhất nhật quá nhất nhật",
            startPage: 14,
            endPage: 20,
          ),
          Chapter(
            title:
                "Chương 2. Một cách thần hiệu để giải quyết những vấn đề rắc rố",
            startPage: 24,
            endPage: 28,
          ),
          Chapter(
            title: "Chương 3. Giết ta bằng cái ưu sầu",
            startPage: 31,
            endPage: 39,
          ),
        ],
      ),
      Phan(
        title: "PHẦN II. NHỮNG THUẬT CĂN BẢN ĐỂ PHÂN TÍCH NHỮNG VẤN ĐỀ RẮC RỐI",
        chapters: [
          Chapter(
            title:
                "Chương 4. Làm sao phân tích và giải quyết những vấn đề rắc rối",
            startPage: 44,
            endPage: 49,
          ),
          Chapter(
            title:
                "Chương 5. Làm sao trừ được 50% lo lắng về công việc làm ăn của chúng ta?",
            startPage: 52,
            endPage: 54,
          ),
          Chapter(title: "TÓM TẮT PHẦN II", startPage: 57, endPage: 59),
        ],
      ),
      Phan(
        title: "PHẦN III. DIỆT TẬT ƯU PHIỀN ĐI ĐỪNG ĐỂ NÓ DIỆT TA",
        chapters: [
          Chapter(
            title: "Chương 6. Khuyên ai chớ có ngồi rồi",
            startPage: 64,
            endPage: 69,
          ),
          Chapter(
            title: "Chương 7. Đời người ngắn lắm ai ơi!",
            startPage: 72,
            endPage: 76,
          ),
          Chapter(
            title: "Chương 8. Một định lệ diệt được nhiều lo lắng",
            startPage: 79,
            endPage: 82,
          ),
          Chapter(
            title: "Chương 9. Đã không tránh được thì nhận đi",
            startPage: 85,
            endPage: 91,
          ),
          Chapter(title: "Chương 10. 'Tốp' lo lại", startPage: 94, endPage: 97),
          Chapter(
            title: "Chương 11. Đừng mất công cưa vụn mạt cưa",
            startPage: 100,
            endPage: 103,
          ),
        ],
      ),
      Phan(
        title:
            "PHẦN IV. BẢY CÁCH LUYỆN TINH THẦN ĐỂ ĐƯỢC THẢNH THƠI VÀ HOAN HỈ",
        chapters: [
          Chapter(
            title: "Chương 12. Một câu đủ thay đổi đời bạn",
            startPage: 108,
            endPage: 117,
          ),
          Chapter(
            title:
                "Chương 13. Hiềm thù rất tai hại và bắt ta trả một giá rất đắt",
            startPage: 120,
            endPage: 125,
          ),
          Chapter(
            title:
                "Chương 14. Nếu bạn làm đúng theo đây thì sẽ không bao giờ còn buồn vì lòng bạc bẽo của người đời",
            startPage: 128,
            endPage: 133,
          ),
          Chapter(
            title:
                "Chương 15. Bạn có chịu đổi cái bạn có để lấy một triệu Mỹ kim không?",
            startPage: 135,
            endPage: 140,
          ),
          Chapter(title: "Chương 16. Ta là ai?", startPage: 142, endPage: 146),
          Chapter(
            title:
                "Chương 17. Định mệnh chỉ cho ta một trái chanh hãy làm thành một ly nước chanh ngon ngọt",
            startPage: 149,
            endPage: 153,
          ),
          Chapter(
            title: "Chương 18. Làm sao trị được bệnh u uất trong hai tuần",
            startPage: 156,
            endPage: 165,
          ),
          Chapter(title: "TÓM TẮT PHẦN IV", startPage: 168, endPage: 168),
        ],
      ),
    ],
    pdfPath: "assets/pdf/nhasachmienphi-quang-ganh-lo-di-va-vui-song.pdf",
  ),
  Book(
    title: 'Nghĩ giàu và làm giàu',
    coverImage: 'assets/images/nghigiaulamgiau.jpg',
    phans: [
      Phan(
        title: "PHẦN I. NGHĨ GIÀU VÀ LÀM GIÀU",
        chapters: [
          Chapter(title: "LỜI NÓI ĐẦU - KHÁT VỌNG", startPage: 1, endPage: 34),
          Chapter(title: "CHƯƠNG 1 - KHÁT VỌNG", startPage: 36, endPage: 53),
          Chapter(title: "CHƯƠNG 2 - NIỀM TIN", startPage: 55, endPage: 75),
          Chapter(title: "CHƯƠNG 3 - TỰ KỶ ÁM THỊ", startPage: 77, endPage: 83),
          Chapter(
            title: "CHƯƠNG 4 - KIẾN THỨC CHUYÊN MÔN",
            startPage: 85,
            endPage: 99,
          ),
          Chapter(
            title: "CHƯƠNG 5 - ÓC TƯỞNG TƯỢNG",
            startPage: 101,
            endPage: 115,
          ),
          Chapter(
            title: "CHƯƠNG 6 - LẬP KẾ HOẠCH",
            startPage: 117,
            endPage: 154,
          ),
          Chapter(
            title: "CHƯƠNG 7 - TÍNH QUYẾT ĐOÁN",
            startPage: 156,
            endPage: 169,
          ),
          Chapter(
            title: "CHƯƠNG 8 - LÒNG KIÊN TRÌ",
            startPage: 171,
            endPage: 187,
          ),
          Chapter(
            title: "CHƯƠNG 9 - SỨC MẠNH CỦA NHÓM TRÍ TUỆ ƯU TÚ",
            startPage: 189,
            endPage: 200,
          ),
          Chapter(title: "CHƯƠNG 10 - TÌNH DỤC", startPage: 202, endPage: 217),
        ],
      ),
    ],
    pdfPath: 'assets/pdf/nghigiaulamgiau.pdf',
  ),
];
