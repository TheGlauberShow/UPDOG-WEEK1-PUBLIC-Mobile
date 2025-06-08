package mobile.backend; // Define que esta classe pertence ao pacote 'mobile.backend'

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.utils.AssetType;
import openfl.utils.ByteArray;
import openfl.utils.Assets; // A classe principal para ativos internos

// Importações para demonstrar o contraste com o acesso "externo" ao sistema de arquivos
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;

/**
 * Esta classe `AssetExamples` atua como um ajudante para demonstrar e centralizar
 * o uso da API OpenFL `Assets` para carregar e gerenciar recursos (assets) internos
 * do seu aplicativo.
 *
 * Recursos internos são aqueles que são empacotados diretamente com o seu aplicativo
 * durante a compilação (imagens, sons, fontes, arquivos de dados, etc.). A API `Assets`
 * oferece uma maneira unificada e multiplataforma para acessá-los, abstraindo as
 * particularidades de cada sistema operacional (Windows, macOS, Linux, Android, iOS, HTML5, etc.).
 *
 * Para que os métodos de carregamento de assets funcionem, você precisa ter os arquivos
 * de recursos especificados no seu arquivo `project.xml` na tag `<assets>`.
 * Exemplo no `project.xml`:
 * ```xml
 * <assets path="Assets" rename="assets" />
 * ```
 * E dentro da pasta 'Assets' do seu projeto, ter os seguintes arquivos de exemplo:
 * - 'image.png' (ou .jpg, .gif)
 * - 'sound.mp3' (ou .wav, .ogg)
 * - 'font.ttf' (ou .otf)
 * - 'text_data.txt'
 * - 'json_data.json'
 */
/*
 * @author OpenFL Team & GXDLOLOLOLOLOLXD2
 *
 * Exemplo de uso da API Assets do OpenFL
 * Este exemplo cobre:
 * 1. Verificação de existência de assets
 * 2. Carregamento de imagens (BitmapData)
 * 3. Carregamento de sons
 * 4. Carregamento de fontes
 * 5. Carregamento de arquivos de texto
 * 6. Carregamento de bytes brutos (JSON, XML, etc.)
 * 7. Listagem de todos os assets disponíveis
 * 8. Listagem de assets por tipo (imagem, som, fonte, etc.)
 * 9. Carregamento assíncrono de assets
 *
 * Nota: Este exemplo é focado em assets internos do aplicativo.
 * Para acessar e manipular arquivos externos (como dados salvos pelo usuário,
 * logs, downloads), você DEVE usar a API `openfl.filesystem.File` e `FileStream`.
 */
class AssetExamples extends Sprite
{
    /**
     * Construtor da classe AssetExamples.
     * Adiciona um listener para quando o sprite for adicionado ao palco,
     * iniciando os exemplos.
     */
    public function new()
    {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    /**
     * Método chamado quando o sprite é adicionado ao palco.
     * Contém a lógica principal de demonstração dos métodos de Assets.
     */
    private function onAddedToStage(e:Event):Void
    {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage); // Remove o listener para evitar chamadas duplicadas

        trace("--- Iniciando Exemplos de Assets ---");

        // --- 1. Verificando a existência de um asset ---
        // Finalidade: Confirmar se um asset interno do aplicativo está disponível para uso.
        //
        // O "Contrário" (Método Externo): `openfl.filesystem.File.exists(path:String)`
        //   - `File.exists()`: Verifica a existência de um arquivo ou diretório **FISICAMENTE NO SISTEMA DE ARQUIVOS**
        //     do dispositivo (ex: no disco rígido do PC, armazenamento interno do celular).
        //     Usado para arquivos que não são parte do pacote do seu jogo, como saves de jogo ou arquivos baixados.
        //
        // Método Interno (Preferível para Assets): `Assets.exists(id:String, ?type:AssetType)`
        //   - `Assets.exists()`: Verifica se um asset **EMBUTIDO NO SEU APLICATIVO** (via `project.xml`)
        //     está registrado e pronto para ser carregado pelo OpenFL. Não acessa o sistema de arquivos diretamente.
        if (Assets.exists("assets/image.png", AssetType.IMAGE)) {
            trace("Asset 'assets/image.png' existe e está disponível internamente!");
        } else {
            trace("Asset 'assets/image.png' NÃO existe. Verifique seu project.xml e a pasta Assets.");
        }

        if (Assets.exists("assets/non_existent.txt")) {
            trace("Isso não deveria aparecer, 'assets/non_existent.txt' não existe internamente.");
        } else {
            trace("Asset 'assets/non_existent.txt' corretamente não encontrado internamente.");
        }

        // --- 2. Carregando uma imagem (BitmapData) ---
        // Finalidade: Obter os dados de pixels de uma imagem para exibição.
        //
        // O "Contrário" (Método Externo):
        //   Você leria os bytes da imagem do disco usando `openfl.filesystem.FileStream`
        //   e então criaria uma `BitmapData` a partir desses bytes com `openfl.display.BitmapData.loadFromBytes()`.
        //   Exemplo (conceitual, não execute diretamente sem um caminho válido):
        //   var externalImageFile = File.userDirectory.resolvePath("fotos/minha_foto.jpg");
        //   var externalStream = new FileStream();
        //   externalStream.open(externalImageFile, FileMode.READ);
        //   var imageBytes = new ByteArray();
        //   externalStream.readBytes(imageBytes);
        //   externalStream.close();
        //   var externalBitmapData = BitmapData.loadFromBytes(imageBytes);
        //
        // Método Interno (Preferível para Assets): `Assets.getBitmapData(id:String)`
        //   - Muito mais simples e seguro para imagens empacotadas no aplicativo.
        try {
            var bitmapData:BitmapData = Assets.getBitmapData("assets/image.png");
            var bitmap:Bitmap = new Bitmap(bitmapData);
            bitmap.x = 10;
            bitmap.y = 10;
            addChild(bitmap);
            trace("Imagem 'assets/image.png' carregada e exibida.");
        } catch (e:Dynamic) {
            trace("Erro ao carregar imagem 'assets/image.png': " + e);
        }

        // --- 3. Carregando um som ---
        // Finalidade: Obter um objeto de som para reprodução.
        //
        // O "Contrário" (Método Externo):
        //   Você leria os bytes do arquivo de som com `openfl.filesystem.FileStream`
        //   e então usaria `openfl.media.Sound.fromFile(filePath)` (se disponível) ou
        //   `Sound.fromAudioBuffer()` (se você tiver uma forma de converter os bytes em um buffer de áudio).
        //
        // Método Interno (Preferível para Assets): `Assets.getSound(id:String)`
        //   - Direto e eficiente para sons empacotados.
        try {
            var sound:Sound = Assets.getSound("assets/sound.mp3");
            // sound.play(); // Descomente esta linha para tocar o som
            trace("Som 'assets/sound.mp3' carregado.");
        } catch (e:Dynamic) {
            trace("Erro ao carregar som 'assets/sound.mp3': " + e);
        }

        // --- 4. Carregando uma fonte ---
        // Finalidade: Obter um objeto de fonte para usar em campos de texto.
        //
        // O "Contrário" (Método Externo):
        //   Não há um método direto em `FileSystem` para carregar fontes de forma que
        //   elas possam ser usadas facilmente com `TextFormat`. Isso exigiria um parsing
        //   manual complexo do arquivo da fonte.
        //
        // Método Interno (Preferível para Assets): `Assets.getFont(id:String)`
        //   - Simplifica enormemente o uso de fontes personalizadas no aplicativo.
        try {
            var font:Font = Assets.getFont("assets/font.ttf");
            var textField:TextField = new TextField();
            // Para usar uma fonte carregada com Assets, use `font.fontName` no `TextFormat`.
            textField.defaultTextFormat = new TextFormat(font.fontName, 24, 0x0000FF);
            textField.text = "Hello OpenFL with Custom Font!";
            textField.autoSize = openfl.text.TextFieldAutoSize.LEFT;
            textField.x = 10;
            textField.y = 150;
            addChild(textField);
            trace("Fonte 'assets/font.ttf' carregada e usada.");
        } catch (e:Dynamic) {
            trace("Erro ao carregar fonte 'assets/font.ttf': " + e);
        }

        // --- 5. Carregando um arquivo de texto ---
        // Finalidade: Obter o conteúdo de um arquivo de texto.
        //
        // O "Contrário" (Método Externo):
        //   Você usaria `openfl.filesystem.FileStream` para ler o conteúdo do arquivo
        //   de texto, convertendo os bytes lidos em uma String.
        //   Exemplo (conceitual):
        //   var externalTextFile = File.userDirectory.resolvePath("docs/readme.txt");
        //   var externalTextStream = new FileStream();
        //   externalTextStream.open(externalTextFile, FileMode.READ);
        //   var textBytes = new ByteArray();
        //   externalTextStream.readBytes(textBytes);
        //   externalTextStream.close();
        //   var externalTextContent = textBytes.readUTFBytes(textBytes.length);
        //
        // Método Interno (Preferível para Assets): `Assets.getText(id:String)`
        //   - Muito mais conveniente para arquivos de texto empacotados.
        try {
            var textContent:String = Assets.getText("assets/text_data.txt");
            trace("Conteúdo de 'assets/text_data.txt':\n" + textContent);
        } catch (e:Dynamic) {
            trace("Erro ao carregar texto 'assets/text_data.txt': " + e);
        }

        // --- 6. Carregando bytes brutos (útil para JSON, XML, binário personalizado) ---
        // Finalidade: Obter o conteúdo binário de um arquivo para processamento customizado.
        //
        // O "Contrário" (Método Externo):
        //   Assim como para imagens e sons, `openfl.filesystem.FileStream` seria usado para
        //   ler os bytes do arquivo diretamente do disco.
        //
        // Método Interno (Preferível para Assets): `Assets.getBytes(id:String)`
        //   - Ideal para arquivos binários internos que precisam de parsing personalizado.
        try {
            var jsonBytes:ByteArray = Assets.getBytes("assets/json_data.json");
            // Uma vez que você tem os bytes, pode processá-los. Por exemplo, como uma String JSON:
            var jsonString:String = jsonBytes.readUTFBytes(jsonBytes.length);
            trace("Conteúdo de 'assets/json_data.json' (como String):\n" + jsonString);

            // Exemplo de como você poderia usar haxe.Json.parse com isso:
            // var data = haxe.Json.parse(jsonString);
            // trace("Dados JSON parseados: " + Reflect.field(data, "keyName")); // Exemplo de acesso a campo
        } catch (e:Dynamic) {
            trace("Erro ao carregar bytes do JSON 'assets/json_data.json': " + e);
        }

        // --- 7. Listando todos os IDs de assets ---
        // Finalidade: Obter uma lista de todos os identificadores de assets conhecidos pelo OpenFL.
        //
        // O "Contrário" (Método Externo):
        //   Exigiria iterar sobre os diretórios e arquivos do sistema de arquivos
        //   usando `FileSystem.readDirectory()` e `File.isDirectory()`, o que é complexo
        //   e não unificado entre plataformas para assets internos empacotados.
        //
        // Método Interno (Preferível para Assets): `Assets.list(?type:AssetType)`
        //   - Fornece uma lista limpa e direta dos IDs de assets que o OpenFL
        //     reconhece e empacotou.
        var allAssets:Array<String> = Assets.list();
        trace("\n--- Lista de todos os Assets reconhecidos ---");
        for (id in allAssets) {
            trace("- " + id);
        }

        // --- 8. Listando assets por tipo ---
        var imageAssets:Array<String> = Assets.list(AssetType.IMAGE);
        trace("\n--- Lista de Assets de Imagem ---");
        for (id in imageAssets) {
            trace("- " + id);
        }

        // --- 9. Carregamento Assíncrono (crucial para Assets grandes ou muitos Assets) ---
        // Finalidade: Carregar assets sem bloquear a interface do usuário.
        //
        // Métodos `get*` (ex: `getBitmapData`, `getSound`) carregam **sincronamente**.
        //   - Isso significa que eles bloqueiam a execução do programa até que o asset
        //     seja totalmente carregado. Pode causar "congelamentos" na UI.
        //
        // Métodos `load*` (ex: `loadBitmapData`, `loadSound`) carregam **assincronamente**.
        //   - Usam `Futures` (objetos que representam um valor que pode estar disponível no futuro).
        //   - Isso permite que seu aplicativo continue respondendo enquanto o carregamento
        //     ocorre em segundo plano. É **altamente recomendado** para assets grandes
        //     ou para carregamentos em massa para manter a fluidez da aplicação.
        trace("\n--- Carregando Imagem Assincronamente ---");
        Assets.loadBitmapData("assets/image.png").onComplete(function(bmd:BitmapData) {
            var asyncBitmap:Bitmap = new Bitmap(bmd);
            asyncBitmap.x = 250;
            asyncBitmap.y = 10;
            addChild(asyncBitmap);
            trace("Imagem 'assets/image.png' carregada assincronamente e exibida.");
        }).onError(function(e:Dynamic) {
            trace("Erro ao carregar imagem assincronamente: " + e);
        });

        // --- Exemplo de Acesso "Externo" com openfl.filesystem.File (Apenas para Contraste) ---
        // Este bloco de código demonstra como você usaria `openfl.filesystem.File` e `FileStream`
        // para manipular arquivos no sistema de arquivos do usuário.
        //
        // **IMPORTANTE:** Este NÃO é o método para carregar assets do seu jogo que são
        // empacotados internamente. Use-o SOMENTE para dados externos ao pacote do seu aplicativo.
        trace("\n--- Exemplo de Acesso 'Externo' com openfl.filesystem.File ---");
        trace("  (Não use para assets do jogo, apenas para dados do usuário!)");

        var externalFilePath:String = "temp_data.txt"; // Nome do arquivo a ser criado/acessado
        // Tenta resolver o caminho no diretório de armazenamento do aplicativo.
        // `File.applicationStorageDirectory` é geralmente o diretório mais confiável
        // para escrita em todas as plataformas (incluindo HTML5 com algumas limitações).
        var externalFile:File = File.applicationStorageDirectory.resolvePath(externalFilePath);

        try {
            trace("Caminho do arquivo externo: " + externalFile.nativePath);

            // Escrevendo no arquivo externo
            var fileStreamWrite:FileStream = new FileStream();
            fileStreamWrite.open(externalFile, FileMode.WRITE);
            fileStreamWrite.writeUTFBytes("Este é um dado salvo externamente usando FileSystem.");
            fileStreamWrite.close();
            trace("Dados salvos externamente em: " + externalFile.nativePath);

            // Lendo do arquivo externo
            if (externalFile.exists) { // Usando File.exists para verificar se o arquivo externo foi salvo
                var fileStreamRead:FileStream = new FileStream();
                fileStreamRead.open(externalFile, FileMode.READ);
                var readBytes:ByteArray = new ByteArray();
                fileStreamRead.readBytes(readBytes);
                trace("Dados lidos externamente: " + readBytes.readUTFBytes(readBytes.length));
                fileStreamRead.close();

                // Opcional: Deletar o arquivo temporário
                // externalFile.deleteFile();
                // trace("Arquivo externo temporário deletado.");
            } else {
                trace("Arquivo externo não encontrado após a tentativa de escrita. Verifique permissões.");
            }
        } catch (e:Dynamic) {
            trace("Erro ao manipular arquivo externo: " + e);
            trace("Note que em HTML5, o acesso a FileSystem.File é restrito por segurança do navegador.");
            trace("Em mobile e desktop, permissões de escrita/leitura podem ser necessárias.");
        }
    }
}