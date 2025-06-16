package mobile.backend;

import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;
import openfl.utils.ByteArray;

import openfl.utils.Assets as OpenFlAssets;

//import haxe.concurrent.Future;
#if sys
import sys.io.File;
#end

/**
 * `AssetUtils` é uma classe utilitária estática que fornece métodos convenientes
 * para acessar assets internos do seu projeto OpenFL.
 *
 * Ao contrário de `AssetExamples` (que é um `Sprite` para demonstração visual),
 * `AssetUtils` não precisa ser instanciado e seus métodos podem ser chamados
 * diretamente usando `mobile.backend.AssetUtils.methodName()`.
 *
 * Para que os métodos de carregamento de assets funcionem, você precisa ter os arquivos
 * de recursos especificados no seu arquivo `project.xml` na tag `<assets>`.
 * Exemplo no `project.xml`:
 * ```xml
 * <assets path="Assets" rename="assets" />
 * ```
 * E dentro da pasta 'Assets' do seu projeto, ter os arquivos de exemplo:
 * - 'image.png' (ou .jpg, .gif)
 * - 'sound.mp3' (ou .wav, .ogg)
 * - 'font.ttf' (ou .otf)
 * - 'text_data.txt'
 * - 'json_data.json'
 */
class AssetUtils
{
    /**
     * Verifica se um asset interno existe.
     * @param id O identificador do asset (ex: "assets/image.png").
     * @param type O tipo do asset (opcional, ex: AssetType.IMAGE).
     * @return True se o asset existir, false caso contrário.
     *
     * O "Contrário" (Método Externo): `openfl.filesystem.File.exists(path:String)`
     * - `File.exists()`: Verifica a existência de um arquivo ou diretório **NO SISTEMA DE ARQUIVOS** do dispositivo.
     * É para arquivos que não são parte do pacote do seu jogo (saves, downloads).
     * 
     * Comando: `mobile.backend.AssetUtils.assetExists("id", type)`
     */
    public static function assetExists(id:String, ?type:AssetType):Bool
    {
        //NativeAPI.showMessageBox("Asset Exists", "Checking if asset '${id}' exists: ${Assets.exists(id, type)}");
        return openfl.utils.Assets.exists(id, type);
    }

    /**
     * Carrega e retorna os dados de bitmap de uma imagem interna.
     * @param id O identificador do asset da imagem (ex: "assets/background.jpg").
     * @return Um objeto BitmapData.
     *
     * O "Contrário" (Método Externo):
     * Você leria bytes de um arquivo de imagem com `FileStream` e depois usaria
     * `BitmapData.loadFromBytes()` para criar o BitmapData.
     */
    public static function getBitmap(id:String):BitmapData
    {
        try {
            return openfl.utils.Assets.getBitmapData(id);
        } catch (e:Dynamic) {
            trace('Error in load image "${id}": ${e}');
            return null; // Retorna null em caso de erro
        }
    }

    /**
     * Carrega e retorna um objeto Sound de um arquivo de áudio interno.
     * @param id O identificador do asset de som (ex: "assets/music.mp3").
     * @return Um objeto Sound.
     *
     * O "Contrário" (Método Externo):
     * Você leria bytes de um arquivo de áudio com `FileStream` e tentaria criar
     * um Sound a partir deles (por exemplo, `Sound.fromFile()`).
     */
    public static function getSound(id:String):Sound
    {
        try {
            return openfl.utils.Assets.getSound(id);
        } catch (e:Dynamic) {
            trace('Error in load sound "${id}": ${e}');
            return null;
        }
    }

    /**
     * Carrega e retorna um objeto Font de um arquivo de fonte interna.
     * @param id O identificador do asset da fonte (ex: "assets/myFont.ttf").
     * @return Um objeto Font.
     *
     * O "Contrário" (Método Externo):
     * Não há uma API direta para carregar fontes de arquivos arbitrários do sistema
     * de arquivos para uso fácil com `TextFormat`. Seria um processo manual complexo.
     */
    public static function getFont(id:String):Font
    {
        try {
            return openfl.utils.Assets.getFont(id);
        } catch (e:Dynamic) {
            trace('Error in load font "${id}": ${e}');
            return null;
        }
    }

    /**
     * Carrega e retorna o conteúdo de um arquivo de texto interno como String.
     * @param id O identificador do asset de texto (ex: "assets/data.txt").
     * @return O conteúdo do arquivo como String.
     *
     * O "Contrário" (Método Externo):
     * Você leria os bytes de um arquivo de texto com `FileStream` e os converteria para String.
     */
    public static function getText(id:String):String
    {
        try {
            return openfl.utils.Assets.getText(id);
        } catch (e:Dynamic) {
            trace('Error in load text "${id}": ${e}');
            return null;
        }
    }

    /**
     * Carrega e retorna os bytes brutos de um arquivo interno (útil para JSON, XML, binário).
     * @param id O identificador do asset (ex: "assets/config.json").
     * @return Um objeto ByteArray.
     *
     * O "Contrário" (Método Externo):
     * Você leria os bytes de um arquivo arbitrário do sistema de arquivos com `FileStream`.
     */
    public static function getBytes(id:String):ByteArray
    {
        try {
            return openfl.utils.Assets.getBytes(id);
        } catch (e:Dynamic) {
            trace('Error in load bytes "${id}": ${e}');
            return null;
        }
    }

    /**
     * Lista todos os IDs de assets internos disponíveis, opcionalmente filtrados por tipo.
     * @param type O tipo do asset para filtrar (opcional).
     * @return Uma Array de Strings com os IDs dos assets.
     *
     * O "Contrário" (Método Externo):
     * Você usaria `openfl.filesystem.File.readDirectory()` para listar arquivos
     * e subdiretórios em um caminho específico no sistema de arquivos.
     */
    public static function listFromPrefix(prefix:String):Array<String>
    {
        return openfl.utils.Assets.list(prefix, null);
    }
    public static function listOpenFL(prefix:String):Array<String>
    {
        return openfl.utils.Assets.list(prefix);
    }

     // update, example: var song:Array<String> = AssetUtils.listAssetsByType(AssetType.SOUND);
    public static function listAssetsByType(?type:Null<AssetType>):Array<String>
    {
        return openfl.utils.Assets.list(type);
    }
    // ou este usando o OpenFLAssets
    // Exemplo: var file:Array<String> = AssetUtils.listAssetsFromPrefix("assets/songs/");
    public static function listAssetsFromPrefix(prefix:String):Array<String>
    {
        return OpenFlAssets.list(prefix, null);
    }

    /**
     * Lê o conteúdo de um asset interno (arquivo embutido no app) como texto.
     * 
     * @param id O caminho do asset (ex: "assets/data.txt").
     * @return O conteúdo do arquivo como String, ou null se não encontrado.
     *
     * Exemplo de uso:
     * ```haxe
     * var texto = mobile.backend.AssetUtils.getAssetContent("assets/data.txt");
     * if (texto != null) trace(texto);
     * else trace("Arquivo não encontrado!");
     * ```
     *
     * Este método é o "contrário" de File.getContent para assets internos:
     * - File.getContent lê arquivos do sistema de arquivos do dispositivo (externo).
     * - getAssetContent lê arquivos embutidos no app (interno), usando OpenFL Assets.
     */
    public static function getAssetContent(id:String):String
    {
        if (Assets.exists(id)) {
            return Assets.getText(id);
        }
        return null;
    }

    // --- Métodos assíncronos (retornam Future) ---

    /**
     * Carrega assincronamente e retorna os dados de bitmap de uma imagem interna.
     * @param id O identificador do asset da imagem.
     * @return Um Future<BitmapData>.
     */
    /*public static function loadBitmapAsync(id:String):Future<BitmapData>
    {
        return Assets.loadBitmapData(id);
    }

    /**
     * Carrega assincronamente e retorna um objeto Sound de um arquivo de áudio interno.
     * @param id O identificador do asset de som.
     * @return Um Future<Sound>.
     */
    /*public static function loadSoundAsync(id:String):Future<Sound>
    {
        return Assets.loadSound(id);
    }

    /**
     * Carrega assincronamente e retorna o conteúdo de um arquivo de texto interno como String.
     * @param id O identificador do asset de texto.
     * @return Um Future<String>.
     */
    /*public static function loadTextAsync(id:String):Future<String>
    {
        return Assets.loadText(id);
    }

    /**
     * Carrega assincronamente e retorna os bytes brutos de um arquivo interno.
     * @param id O identificador do asset.
     * @return Um Future<ByteArray>.
     */
    /*public static function loadBytesAsync(id:String):Future<ByteArray>
    {
        return Assets.loadBytes(id);
    }*/
}